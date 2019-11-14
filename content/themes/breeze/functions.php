<?php

/** Load composer autoloader */
require_once(realpath(__DIR__ . '/../../../vendor/autoload.php'));

/** Load application without autoloader */
require_once(realpath(__DIR__ . '/Application.php'));

/** Create and configure application */
$application = new \Application(
  require(realpath(__DIR__ . '/src/config.php'))
);

/** Bootstrap application */
$application->bootstrap()->run();
