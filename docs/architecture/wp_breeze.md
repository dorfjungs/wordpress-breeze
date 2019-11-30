# WP-Breeze
The wp-breeze package is just an abstractio layer for wordpress.
So you don't need to deal with the mess that comes with wordpress.

## View controllers
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


### Overriding the default template
You can't. Since this template can be useful for testing countainers state it will remain static. This forces the editor to select a custom template in the backend

## View helpers
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

### Registering the view helper
To register a view helper simply tell the config:

```php
'wp_breeze_view_helpers' => [
  \Breeze\ViewHelpers\AjaxUrlViewHelper::class
]
```

### Using the view helper
After you've registered the view helper you can use the view helper by simply calling a function named after the view helper:

```html
<a href="{{ajax_url('action_name', { 'param1': 'test' })}}">
```

## Actions
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


### Adding priority and parameter quantification to the action
Since we're bound to some wordpress patterns you can define a priority and the parameter count like this (both optional and not mutually exclusive):

```php
public $hook = 'body_class(10, 3)';
```

### Registering the action
Actions are simple to register:

```php
'wp_breeze_actions' => [
  \Breeze\Actions\BodyClassAction::class
]
```