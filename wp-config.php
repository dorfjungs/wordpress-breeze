<?php
// BEGIN iThemes Security - Do not modify or remove this line
// iThemes Security Config Details: 2
define( 'DISALLOW_FILE_EDIT', true ); // Disable File Editor - Security > Settings > WordPress Tweaks > File Editor
// END iThemes Security - Do not modify or remove this line

/**
 * The base configurations of the WordPress.
 *
 * This file has the following configurations: MySQL settings, Table Prefix,
 * Secret Keys, and ABSPATH. You can find more information by visiting
 * {@link https://codex.wordpress.org/Editing_wp-config.php Editing wp-config.php}
 * Codex page. You can get the MySQL settings from your web host.
 *
 * This file is used by the wp-config.php creation script during the
 * installation. You don't have to use the web site, you can just copy this file
 * to "wp-config.php" and fill in the values.
 *
 * @package WordPress
 */

/** Revert Proxy Fix */
if (
  array_key_exists('HTTP_X_FORWARDED_PROTO', $_SERVER) &&
  $_SERVER['HTTP_X_FORWARDED_PROTO'] === 'https'
) {
	$_SERVER['HTTPS'] = 'on';
	$_SERVER['SERVER_PORT'] = '443';

	define('FORCE_SSL_ADMIN', true);
}

if (isset($_SERVER['HTTP_X_FORWARDED_HOST'])) {
	$_SERVER['HTTP_HOST'] = $_SERVER['HTTP_X_FORWARDED_HOST'];
}

/** Environment helper */
function env(string $name, $default = null) {
	return getenv($name) ? getenv($name) : $default;
}

/** Base url helper */
function url($url = '') {
  return sprintf(
    '%s://%s/%s',
    array_key_exists('HTTPS', $_SERVER) && 'on' === $_SERVER['HTTPS']
      ? 'https'
      : 'http',
    $_SERVER['HTTP_HOST'],
    $url
  );
}

/** Define application environment if not found */
if ( ! defined('APPLICATION_ENV')) {
	define('APPLICATION_ENV', env('APPLICATION_ENV', 'production'));
}

/** Define if in development or production mode */
define('DEVELOPMENT', in_array(APPLICATION_ENV, ['dev', 'development']));
define('PRODUCTION', ! DEVELOPMENT);

// ** MySQL settings - You can get this info from your web host ** //
/** The name of the database for WordPress */
define('DB_NAME', env('DATABASE_NAME', 'wodpress-breeze'));

/** MySQL database username */
define('DB_USER', env('DATABASE_USER', 'root'));

/** MySQL database password */
define('DB_PASSWORD', env('DATABASE_PASS', ''));

/** MySQL hostname */
define('DB_HOST', env('DATABASE_HOST', 'localhost'));

/** Database Charset to use in creating database tables. */
define('DB_CHARSET', env('DATABASE_CHARSET', 'utf8'));

/** The Database Collate type. Don't change this if in doubt. */
define('DB_COLLATE', env('DATABASE_COLLATE', ''));

/** Folder restructuring **/
define('WP_CONTENT_DIR', dirname(__FILE__) . '/content');

/** URL restructuring **/
define('WP_CONTENT_URL', url('content'));

// ** Security settings - Depends on your app env ** //
/** Enable all core updates, including minor and major */
define('WP_AUTO_UPDATE_CORE', false);

/** Disable Error Reporting */
if (PRODUCTION) {
    error_reporting(0);
    @ini_set('display_errors', 0);
}

/** Disallow file edit */
define('DISALLOW_FILE_EDIT', PRODUCTION);

/** Disallow auto p in contact form 7 */
define('WPCF7_AUTOP', false);

/** WP-Rocket config */
define('WP_ROCKET_EMAIL', env('WP_ROCKET_EMAIL', ''));
define('WP_ROCKET_KEY', env('WP_ROCKET_KEY', ''));
define('WP_CACHE', PRODUCTION); // Added by WP Rocket

/**
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY', '|#)*5+^+C)7W|2kO/#t;gbtx6.bp#/-[o_ipKVZG+;.4MQ/@cv9]|q8<A75*8oB<');
define('SECURE_AUTH_KEY', '[Gi`7*U#g+bJ,Rx!He{Z$KCT|q~VtAcw`Tp5]t.bkya!+3@DR7>tOum+5/M.6IOw');
define('LOGGED_IN_KEY', '$zCi^kQJrGm~31l[KcD*C1~4<Cti2$FS`:;cOUSGq5n}=dtTfn<gbN2t^pjbpjN_');
define('NONCE_KEY', 'ui8AU|J*Wv3cYrx%!GwDV&cU1-4_Y22t-P2t+7t: ;C+.|36>n). )^3J|_WV$p4');
define('AUTH_SALT', 'KNmGtJB0 $;SW@{khs?EL[p}f?%K=|3r[bb)w#/-cEZ:>&A2Y17xS22FRml<<;#&');
define('SECURE_AUTH_SALT', 'G.@_C:|2GM~>N]o$p-IZlr&<bL rod}+ofMjwD5iR%3&A09]{h-]ppU5Vc+:XRkR');
define('LOGGED_IN_SALT', 'Few0-V!kM}yOz2&P=@n5w>~vVapw`~(w-fwc1YSi?($58wxbCHiS%?+WdgVT$*OS');
define('NONCE_SALT', ']z<#Rl{B7Vvjg{-/s;Q?Dyt,o 7]lOx|tFYFG[GMd)`gaf/nNU#JCrn!L6[~i)^I');

/**
 * Ensure SSL
 */
define('FORCE_SSL_LOGIN', PRODUCTION ? true : false);
define('FORCE_SSL_ADMIN', PRODUCTION ? true : false);

/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each a unique
 * prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = env('WP_TABLE_PREFIX', 'wpbr_');

/** Disable WP-Cron because it sucks */
define('DISABLE_WP_CRON', true);

/**
 * For developers: WordPress debugging mode.
 *
 * Change this to true to enable the display of notices during development.
 * It is strongly recommended that plugin and theme developers use WP_DEBUG
 * in their development environments.
 */
define('WP_DEBUG', !PRODUCTION);

/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( ! defined('ABSPATH')) {
	define('ABSPATH', dirname(__FILE__) . '/');
}

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');

/** Define home and site url */
define('WP_HOME', url());
define('WP_SITEURL', url('wordpress'));
