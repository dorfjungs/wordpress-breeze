<?php
use WpBreeze\Actions\NavMenuAction;
use WpBreeze\Actions\AdminBarAction;
use WpBreeze\Actions\AcfBreezeAction;
use WpBreeze\Actions\BodyClassAction;
use WpBreeze\Actions\ImageSizeAction;
use WpBreeze\Actions\TitleAjaxAction;
use WpBreeze\Actions\LoginAssetAction;
use WpBreeze\Actions\DefaultAssetAction;

class Application extends \WpBreeze\Application {
  /**
   * @var string
   */
  public static $name = 'base';

  /**
   * @var string
   */
  protected $resourcePath = 'assets';

  /**
   * @var array
   */
  protected $config = [];

  /**
   * @param array $config
   */
  public function __construct($config = []) {
    parent::__construct(static::$name);

    $this->config = $config;

    $this->addViewHelpers($config['wp_breeze_view_helpers']);
    $this->addActions($config['wp_breeze_actions']);
    $this->registerOptionPages($config['acf_breeze_option_pages']);
    $this->syncPages();

  }

  /**
   * @return self
   */
  public static function get($id = '') {
    return parent::get(static::$name);
  }

  /**
   * @return void
   */
  protected function syncPages() {
    $ext = '.php';
    $pages = $this->config['wp_pages'];
    $rootPath = realpath(__DIR__);
    $pagesPath = realpath(__DIR__ . '/pages');
    $rootFiles = scandir($rootPath);
    $pagesFiles = scandir($pagesPath);

    // Wordpress default templates 
    // https://developer.wordpress.org/themes/basics/template-files/
    $wpDefaultTemplates = [
      'index',
      'comments',
      'front-page',
      'home',
      'singular',
      'single',
      'single-*',
      'archive',
      'archive-*',
      'page',
      'page-*',
      'category',
      'tag',
      'taxonomy',
      'author',
      'date',
      'search',
      'attachment',
      'image',
      '404',
    ];

    $wpDefaultPages = [];
    $wpCustomPages = [];
    foreach ($pages as $pageKey => $pageValue) {
      $wpDefaultTemplateMatched = false;
      foreach ($wpDefaultTemplates as $wpDefaultTemplate) {
        if ((
            $wpDefaultTemplate == (string) $pageKey ||
            (substr($wpDefaultTemplate, -1) === '*' 
              && strpos($pageKey, substr($wpDefaultTemplate, 0, strlen($wpDefaultTemplate) - 1)) === 0)
          )
        ) {
          $wpDefaultTemplateMatched = true;
          break;
        }
      }

      if ($wpDefaultTemplateMatched === true) {
        $wpDefaultPages[] = (string) $pageKey;
      } else {
        $wpCustomPages[] = (string) $pageKey;
      }
    }

    /**
     * WordPress Default Templates Magic
     */
    foreach ($rootFiles as $rootFile) {
      $path = $rootPath . '/' . $rootFile;
      $pathInfo = pathinfo($path);
      
      if (!isset($pathInfo['extension']) || '.' . $pathInfo['extension'] != $ext) {
        continue;
      }

      if (in_array($pathInfo['filename'], $wpDefaultPages)) {
        unlink($path);
      }
    }

    foreach ($wpDefaultPages as $wpDefaultPage) {
      $page = $pages[$wpDefaultPage];
      $name = static::$name;
      $app = "\WpBreeze\Application::get('$name')";
      $file = $rootPath . '/' . $wpDefaultPage . $ext;
      $fileContent = "<?php echo {$app}->controller($page[1])->render();";  

      if ( ! file_exists($file)) {
        file_put_contents($file, $fileContent);
      }
    }
    
    /**
     * Custom Templates Magic
     */
    foreach ($pagesFiles as $pageFile) {
      $path = $pagesPath . '/' . $pageFile;
      $pathInfo = pathinfo($path);
      
      if (!isset($pathInfo['extension']) || '.' . $pathInfo['extension'] != $ext) {
        continue;
      }

      if (in_array($pathInfo['filename'], $wpCustomPages)) {
        unlink($path);
      }
    }

    foreach ($wpCustomPages as $wpCustomPage) {
      $page = $pages[$wpCustomPage];
      $name = static::$name;
      $app = "\WpBreeze\Application::get('$name')";
      $file = $pagesPath . '/' . $wpCustomPage . $ext;
      $fileContent = "<?php /** Template Name: $page[0] */"
                        . "echo {$app}->controller($page[1])->render();";

      if ( ! file_exists($file)) {
        file_put_contents($file, $fileContent);
      }
    }
  }

  /**
   * @param \WpBreeze\Actions\DefaultAssetAction $action
   * @param array $params
   * @return void
   */
  protected function beforeDefaultAssetAction(DefaultAssetAction &$action, &$params) {
    $action->setBaseUrl($this->baseUrl);
  }

  /**
   * @param LoginAssetAction $action
   * @param array $params
   * @return void
   */
  protected function beforeLoginAssetAction(LoginAssetAction &$action, &$params) {
    $action->setBaseUrl($this->baseUrl);
  }

  /**
   * @param AcfBreezeAction $action
   * @param array $params
   * @return void
   */
  protected function beforeAcfBreezeAction(AcfBreezeAction &$action, &$params) {
    $action->registerPackage($this->id, [
      'extends' => $this->config['acf_breeze_extends'],
      'paths' => array_merge([
        realpath(__DIR__ . '/templates/') ],
        $this->config['wp_breeze_template_paths']
      ),
      'groups' => $this->config['acf_breeze_groups'],
      'modules' => $this->config['acf_breeze_modules'],
      'layouts' => $this->config['acf_breeze_layouts']
    ], class_exists('\acf'));
  }

  /**
   * @param array $pages
   */
  protected function registerOptionPages($pages = []) {
    if (function_exists('acf_add_options_page')) {
      foreach ($pages as $page) {
        acf_add_options_page($page);
      }
    }
  }

  /**
   * @param ImageSizeAction $action
   * @param array $params
   * @return void
   */
  protected function beforeImageSizeAction(ImageSizeAction &$action, &$params) {
    if (array_key_exists('wp_image_sizes', $this->config)) {
      $sizes = $this->config['wp_image_sizes'];

      foreach ($sizes as $name => $size) {
        $action->addSize(
          $name,
          array_key_exists('width', $size) ? $size['width'] : 0,
          array_key_exists('height', $size) ? $size['height'] : 0,
          array_key_exists('crop', $size) ? $size['crop'] : false
        );
      }
    }
  }

  /**
   * @param BodyClassAction $action
   * @param array $params
   * @return void
   */
  protected function beforeBodyClassAction(BodyClassAction &$action, &$params) {
    $params['classes'] = ['template-' . str_replace('/', '-', str_replace('.php', '', get_page_template_slug()))];
  }

  /**
   * @param AdminBarAction $action
   * @param array $params
   * @return void
   */
  protected function beforeAdminBarAction(AdminBarAction &$action, &$params) {
    $params['disable'] = false;
  }

  /**
   * @param NavMenuAction $action
   * @param array $params
   * @return void
   */
  protected function beforeNavMenuAction(NavMenuAction &$action, &$params) {
    if (array_key_exists('wp_menus', $this->config)) {
      $params['menus'] = $this->config['wp_menus'];
    }
  }
}
