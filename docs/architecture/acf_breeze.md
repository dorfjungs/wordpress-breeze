# ACF-Breeze
The package acf-breeze is just a simple abstraction layer built on top of acfbuilder, acf and wp-breeze.

## The ACF-Breeze field hierarchy
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

## Using groups
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

## Using layouts
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

## Using modules
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

## Adding the fields to the config
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

## The acfbuilder
The whole structure is build with the package [`StoutLogic/acf-builder`](https://github.com/StoutLogic/acf-builder). So everytime you get the `$builder` variable you can check on the acfbuilder documentation to see what functions are available.