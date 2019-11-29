<?php

$console = realpath(__DIR__ . '/pattern/core/console');
$index = realpath(__DIR__ . '/pattern/public/index.html');

if (file_exists($console)) {
  shell_exec('php ' . $console . ' --generate');
}

if ( ! file_exists($index)) {
  throw new \Exception('No pattern found');
}

include $index;
