# Configuration
Everything you can customize

## Volumes
Volumes are just put into a single directory and linked to the right place inside the container,
so you don't need to worry to put it in the right place.

| Mount point | Required | Description|
| ----------- | ----------- | -------- |
| /var/mnt/vendor | no | Here will the vendor files from composer be placed. So the integrator will have code completion etc. Use this if you're still using code completion for php.
| /var/mnt/composer | yes | The basedir where your `composer.json` is located. This is used to merge de depencencies between the container and your installation. **So make sure a composer.json exists** (and is valid).
| /var/mnt/src | yes | All the source files mapped to the namespace `\Breeze\...`
| /var/mnt/assets | yes | Images, fonts, scripts, styles etc.
| /var/mnt/templates | yes | All twig templates for views, partials etc.
| /var/mnt/uploads | yes | The uploads folder to keep data persistent
| /var/mnt/templates | yes | The twig templates used for the views
| /var/mnt/exports | no | The exports folder. All exports will be placed here

## Environment variables
Environment variables can define specific behavior and information for wordpress.

| Name | Required  | Description |
| ---- | --------- | ----------- |
| DATABASE_HOST | yes | The database host within your services or stack. If the port differs from `3306` you can extend it like: `localhost:1337`
| DATABASE_NAME | yes | The database name of the instance
| DATABASE_USER | yes | The user for the database
| DATABASE_PASS | yes | Database password for the user
| WORDPRESS_HOST | yes | The host (domain) used for the instance
| WORDPRESS_TITLE | yes | The title of your wordpress site
| ADMIN_PASSWORD | yes | The password used for the initial admin user
| APPLICATION_ENV | no | This will do some optimization regarding the current environment Possible options are `dev` and `prod`. Default: `prod`
| PERMALINK_STRUCTURE | no | The permalink structure to use. Default: /blog/%postname%/
| ACF_PRO_KEY | no | The ACF pro key used for the installation
| WP_ROCKET_EMAIL | no | The mail address for wp-rocket pro
| WP_ROCKET_KEY | no | The wp rocket pro key
| PATTERNLAB | no | Set to 1 if pattternlab should be installed
| RESET_DATABASE_ON_STARTUP | no | Set this to 1 if you want to reset the database on startup. Useful for test & staging environments

## Adding composer packages
To add composer packages from the consumer the container will merge his own `composer.json` with the one located in `/var/mnt/composer`.
So make sure a minimal composer.json exists. It should look like this with minimal information:

```json
{
  "name": "yourpackage/app",
  "description": "yourpackage/app"
}
```
> You can add dependencies as usual. The container will check the depndencies after a restart

## Configuring wp and acfbreeze
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
'wp_pages' => [],

/**
 * The menus to add to the wordpress instance
 */
'wp_menus' => [],

/**
 * The image size formats for wordpress
 */
'wp_image_sizes' => []
```