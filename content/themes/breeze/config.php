<?php

return [
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
   * Default: templates
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
   * The image size formats for wordpress. A valid configuration looks
   * like this (All items are optional):
   *
   * 'teaser' => [ 'width' => 600, 'height' => 800, 'crop' => false ]
   */
  'wp_image_sizes' => []
];
