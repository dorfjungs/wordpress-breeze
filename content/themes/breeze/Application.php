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

    // if (DEVELOPMENT) {
    //   exec(' cd ../../../patternlab-core && php core/console --generate');
    // }
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
    $base = realpath(__DIR__ . '/pages');
    $files = scandir($base);

    foreach ($files as $file) {
      $path = $base . '/' . $file;

      if (
        substr_compare($file, $ext, -strlen($ext)) === 0 &&
        is_file($path) &&
        ! array_key_exists(str_replace($ext, '', basename($file)), $pages)
      ) {
        unlink($path);
      }
    }

    foreach ($pages as $name => $page) {
      $file = $base . '/' . $name . $ext;
      $name = static::$name;
      $app = "\WpBreeze\Application::get('$name')";

      if ( ! file_exists($file)) {
        file_put_contents($file,
          "<?php /** Template Name: $page[0] **/"
          . "echo {$app}->controller($page[1])->render();"
        );
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
    $action->addSize('content', 960);
    $action->addSize('teaser', 1024, 576, true);
    $action->addSize('big', 1680);
    $action->addSize('hd', 1920);
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
    $params['menus'] = [
      'primary' => __('Primary Menu'),
      'meta' => __('Meta menu')
    ];
  }
}
