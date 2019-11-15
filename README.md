# Wordpress Breeze
> The less shitty wordpress installation. Still crap, though.

## Why?
I am asking myself the same question and couldn't find an answer to that - yet.
This is simply a basic setup for a specific wordpress architecture to reduce the pain for the developers. It's packed into a docker container. So you basically have a package with the basic stuff required for a minimal wordpress setup (including plugins, settings, users etc.). You're welcome. You only need to attach the corresponding volumes in order to customize the instance. Sounds pretty simple? It is, indeed. But don't get me wrong, wordpress still sucks on a very high level and it will suck as long as there are developers supporting (and using) it. Me included, per se. So consider this package a painkiller for the agony that comes with wordpress.

## Usage
To use this package you can just pull the latest image version from [dockerhub](https://hub.docker.com/r/dorfjungs/wordpress-breeze). The dockerhub covers things like initially installing plugins, creating an admin user with a defined password, creating the database from scratch, injecting the config from the user, dynamically handling wordpress templates (a.k.a pages in this context).

### Integrate inside docker-compose
To use the package inside your a `docker-compose.yml` you can either reference the image directly or create a new `Dockerfile` if you want to do some customization to the base distribution. A basic setup for docker-compose could look like this:

```yml
app:
  image: dorfjungs/wordpress-breeze:v1.0
  volumes:
    vendor:/var/www/app/vendor
    composer:/var/www/app/composer
    src:/var/www/app/content/themes/breeze/src
    assets:/var/www/app/content/themes/breeze/templates
    uploads:/var/www/app/content/uploads
  environment:
    WORDPRESS_HOST: yourpage.localhost
    WORDPRESS_TITLE: yourPage
    DATABASE_HOST: database
    DATABASE_NAME: someDbName
    DATABASE_USER: someDbUser
    DATABASE_PASS: aComplexDatabasePassword
```

### Available volumes
| Mount point | Required | Description|
| ----------- | ----------- | -------- |
| /var/mnt/vendor | no | Here will the vendor files from composer be placed. So the integrator will have code completion etc. Use this if you're still using code completion for php.
| /var/mnt/composer | yes | The basedir where your `composer.json` is located. This is used to merge de depencencies between the container and your installation. **So make sure a composer.json exists** (and is valid).
| /var/mnt/src | yes | All the source files mapped to the namespace `\Breeze\...`
| /var/mnt/assets | yes | Images, fonts, scripts, styles etc.
| /var/mnt/templates | yes | All twig templates for views, partials etc.
| /var/mnt/uploads | yes | The uploads folder to keep data persistent

### Available environment variables
| Name | Required  | Description |
| ---- | --------- | ----------- |
| APPLICATION_ENV | no | This will do some optimization regarding the current environment Possible options are `dev` and `prod`. Default: `prod`
| DATABASE_HOST | yes | The database host within your services or stack. If the port differs from `3306` you can extend it like: `localhost:1337`
| DATABASE_NAME | yes | The database name of the instance
| DATABASE_USER | yes | The user for the database
| DATABASE_PASS | yes | Database password for the user
| WORDPRESS_HOST | yes | The host (domain) used for the instance
| WORDPRESS_TITLE | yes | The title of your wordpress site
| ADMIN_PASSWORD | yes | The password used for the initial admin user
| ACF_PRO_KEY | no | The ACF pro key used for the installation
| WP_ROCKET_EMAIL | no | The mail address for wp-rocket pro
| WP_ROCKET_KEY | no | The wp rocket pro key
> Database should be MySQL

### Configuration
To configure your application to your needs accordingly, you have one entrypoint for all the configurations available to the container, which is located inside the mounted volume under `src/config.php`. The default configuration looks like this:

```php
/**
 * Which package should be used to extend the current modules,
 * layouts and groups from
 */
'acf_breeze_extends' => 'acfbreeze',

/**
 * The ACF modules to use. These will be injected into the
 * base application provided by wp-breeze
 */
'acf_breeze_modules' => [],

/**
 * The ACF groups to use. These will be injected into the
 * base application provided by wp-breeze
 */
'acf_breeze_groups' => [],

/**
 * The ACF layouts to use. These will be injected into the
 * base application provided by wp-breeze
 */
'acf_breeze_layouts' => [],

/**
 * ACF option pages to register through wp-breeze.
 * This will simply be directed to `acf_add_options_page`
 * after some checks
 */
'acf_breeze_option_pages' => [],

/**
 * The wordpress actions (hooks) to register before
 * the application "bootstraps"
 */
'wp_breeze_actions' => [],

/**
 * Simple view helpers for the twig template engine.
 * These will be injected by the twig adaptor from wp-breeze
 */
'wp_breeze_view_helpers' => [],

/**
 * Additional template paths for the wp breeze engine.
 * These will be used as base path for the twig engine.
 * So you can just include twig files inside theses paths.
 * Default: [ templates ]
 */
'wp_breeze_template_paths' => [],

/**
 * The pages to sync with the wordpress instance.
 * This is basically page -> controller -> view (twig)
 */
'wp_pages' => []
```

### The ACF-Breeze field hierarchy
The module `acf-breeze` basically creates a pattern with `acfbuilder`. So there is a definition for the inputs in the backend. The main field types (groups, layouts, modules) basically builds upon this structure:

```
+--------+
| Group  |
+---+----+
    |
+---v----+
| Layout |
+---+----+
    |
+---v----+
| Module |
+--------+
```
> Each type can be used independently off each other

#### Using groups
Groups are the most basic form of fields. They can be used on pages through conditions or custom option pages. For instance, to create a basic navigation theme selection for a selection of pages it would look like this:

```php
namespace Breeze\Fields\Groups;

use AcfBreeze\Builder\Group;
use AcfBreeze\FieldsBuilder;

class NavigationThemeGroup extends Group {
  /**
   * @var string
   */
  protected $title = 'Navigation Theme';

  /**
   * {@inheritDoc}
   */
  protected $params = [
    'locations' => [
      ['post_type', '==', 'post', 'or'],
      ['post_type', '==', 'page', 'and'],
      ['page_template', '==', 'default'],
    ],
  ];

  /**
   * {@inheritDoc}
   */
  public function builder(FieldsBuilder &$builder) {
    parent::builder($builder);

    $builder
      ->addSelect('navigation_theme', [ 'label' => 'Theme' ])
      ->addChoices([ ['dark' => 'Dark'], ['bright' => 'Bright'] ]);
  }
}
```

#### Using layouts
Layouts are used to give the modules a wrapper. As an example you can create multiple layouts inside a group to create separation in form of sections. And inside these layouts you can place the modules in a defined behavior (e.g. with columns). As simple layout putting a repeater fields for the module inside itself would look like this:

```php
namespace Breeze\Fields\Layouts;

use AcfBreeze\FieldsBuilder;
use AcfBreeze\Builder\Field;
use AcfBreeze\Builder\Layout;
use StoutLogic\AcfBuilder\FlexibleContentBuilder;
use StoutLogic\AcfBuilder\FieldsBuilder as StoutLogicFieldsBuilder;

class SimpleLayout extends Layout {
  /**
   * @var string
   */
  protected $title = 'Simple Layout';

  /**
   * @var FlexibleContentBuilder
   */
  private $flexContent = null;

  /**
   * {@inheritDoc}
   */
  protected function builder(FieldsBuilder &$builder) {
      parent::builder($builder);

      // Attach received module as select options under modules_content filed
      $this->flexContent = $field->addTab('Content')->addFlexibleContent(
        'modules_content',
        [ 'label' => __('Modules') ]
      );
  }

  /**
   * @param Field $builder
   * @return void
   */
  public function addModule(Field &$builder) {
    // Receive modules and put them inside the content tab
    $this->flexContent->addLayout($builder->getBuilder());
  }
}
```

#### Using modules
Modules are used inside layouts and layouts **only**. A simple spacer module could look like this:

```php

namespace AcfBreeze\Package\Modules;

use AcfBreeze\Builder\Field;
use AcfBreeze\FieldsBuilder;

class SpacerModule extends Field {
  /**
   * @var string
   */
  protected $title = 'Spacer Module';

  /**
   * @var array
   */
  protected $params = [
    'choices' => [
      ['small' => 'Small'],
      ['medium' => 'Medium'],
      ['large' => 'Large']
    ]
  ];

  /**
   * @param AcfBreeze\FieldsBuilder $builder
   * @return void
   */
  protected function builder(FieldsBuilder &$builder) {
    parent::builder($builder);

    $builder->addSelect('type', ['wrapper' => ['width' => 50]])
            ->addChoices($this->getParam('choices'));
  }
}
```

#### Adding the fields to the config
To add the fileds to the config you can simply assign a name and refer to the fields class (either group, layout or module). Lets say you want to add a group to your fields. That would look like this:

```php
'acf_breeze_groups' => [
  'content' => \Breeze\Groups\ContentGroup::class
]
```

To tell the group to include some layouts you would add a extended configuration array:

```php
'acf_breeze_groups' => [
  'class' => \Breeze\Fields\Groups\ContentGroup::class,

  // The prefix to add before the modules repeater
  'entry' => 'flex_content',

  // This will include all layouts added to this package
  'layouts' => '*'

  // This would include only the "simple layout"
  // 'layouts' => [ 'simple' ]
]
```

Layouts and modules are added in the same manner:
```php
'acf_breeze_layouts' => [
  'simple' => [
    'class' => \Breeze\Fields\Layouts\SimpleLayout::class,
    'modules' => '*'
  ]
]

'acf_breeze_modules' => [
  'spacer' => [
    'class' => \Breeze\Fields\Modules\SpacerModule::class,

    // Override params to fit the needs
    'params' => [
      'choices' => [
        ['sm' => 'SM'],
        ['md' => 'MD']
      ]
    ]
  ]
]

// Or short syntax
'acf_breeze_modules' => [
  'spacer' => \Breeze\Fields\Modules\SpacerModule::class
]
```

You can disable groups, layouts and modules from an inherent package like this:
```php
'acf_breeze_layouts' => [
  'simple' => false
]
```

#### The acfbuilder
The whole structure is build with the package [`StoutLogic/acf-builder`](https://github.com/StoutLogic/acf-builder). So everytime you get the `$builder` variable you can check on the acfbuilder documentation to see what functions are available.


### View controllers with templates (a.k.a pages)
To simplify the whole process from a custom template to the rendered view via `twig`, you can now add a simple mapping to the config with the name of the page to the view controller.
For instance a simple controller for the index page would look like this:

```php
namespace Breeze\Controllers;

use WpBreeze\Controllers\AbstractController;

class IndexController extends AbstractController {
  /**
   * {@inheritDoc}
   */
  public function render() {
    return $this->timber->render('views/index.twig', [
      'customVariable1' => 'test1',
      'customVariable2' => 'test2',
    ]);
  }
}
```

To register the controller with a corresponding page you would register it like this:
```php
'wp_pages' => [
  'index' => [ 'Startpage', '\Breeze\Controllers\IndexController::class' ]
]
```
> Make sure to pass the controller class as a string, since this will be used for code generation


#### Overriding the default template
You can't. Since this template can be useful for testing countainers state it will remain static. This forces the editor to select a custom template in the backend

### View helpers
View helpers are used within a twig template and registered via the config. For instance, lets create an ajax link generator with a view helper

```php
namespace Breeze\ViewHelpers;

class AjaxUrlViewHelper extends AbstractViewHelper {
  /**
   * {@inheritDoc}
   */
  public $name = 'ajax_url';

  /**
   * @param string $action
   * @return string
   */
  public function render($action, $args = []) {
    $argsStr = '';

    foreach ($args as $name => $value) {
      $argsStr .= $name . '=' . $value;
    }

    return (
      rtrim(admin_url(), '/')
        . '/admin-ajax.php?action='
        . $action
        . (!empty($argsStr) ? '&' : '')
        . $argsStr;
  }
}

```

#### Registering the view helper
To register a view helper simply tell the config:

```php
'wp_breeze_view_helpers' => [
  \Breeze\ViewHelpers\AjaxUrlViewHelper::class
]
```

#### Using the view helper
After you've registered the view helper you can use the view helper by simply calling a function named after the view helper:

```html
<a href="{{ajax_url('action_name', { 'param1': 'test' })}}">
```

### Actions (wp actions and filters combined)
Actions are just a combination and abstraction of wordpress action and filter "system". For instance, if you want to add hook into the `body_class` filter you can do it like this:

```php
namespace Breeze\Actions;

use WpBreeze\Actions\AbstractAction;

class BodyClassAction extends AbstractAction {
  /**
   * {@inheritDoc}
   */
  public $name = 'body-class-action';

  /**
   * {@inheritDoc}
   */
  public $hookType = self::HOOK_FILTER; // Default = self::HOOK_ACTION

  /**
   * {@inheritDoc}
   */
  public $hook = 'body_class';

  /**
   * {@inheritDoc}
   */
  public function run($params = []) {
    return array_merge($params['args'][0], [
      'custom-class-1',
      'custom-class-2'
    ]);
  }
}
```
> Now you can share this action across multiple instances or put it into a base library


#### Adding priority and parameter quantification to the action
Since we're bound to some wordpress patterns you can define a priority and the parameter count like this (both optional and not mutually exclusive):

```php
public $hook = 'body_class(10, 3)';
```


#### Registering the action
Actions are simple to register:

```php
'wp_breeze_actions' => [
  \Breeze\Actions\BodyClassAction::class
]
```

## Development
This whole package will be published by the dockerhub build automation. To trigger this you can simply push a tag and dockerhub handles the process for you.

### Creating a new release
To create a new release simply create and push a tag with this format: `^v[0-9].[0-9]+`

## License
See the [LICENSE](./LICENSE) file for license rights and limitations (MIT).