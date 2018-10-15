<?php

/* MySQL settings - You can get this info from your web host */
define('DB_NAME', 		'${WPDB}');
define('DB_USER',		 	'${WPUSER}');
define('DB_PASSWORD', '${WPPASS}');
define('DB_CHARSET', 	'utf8');				// Don't change this if in doubt.
define('DB_HOST', 		'localhost');		// Don't change this if in doubt.
define('DB_COLLATE', 	'');						// Don't change this if in doubt.

/* Salt Keys
* You can generate these using the https://api.wordpress.org/secret-key/1.1/salt/
* You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.		 */
${WP_SALT}

/* MySQL database table prefix. */
$table_prefix  = 'mc_';

/*	EngineScript Server Settings	*/

/* SSL */
define('FORCE_SSL_LOGIN', true);
define('FORCE_SSL_ADMIN', true);

/* Performance */
define('WP_MEMORY_LIMIT', '192M');
define('WP_MAX_MEMORY_LIMIT', '256M');

/* Updates */
define('WP_AUTO_UPDATE_CORE', 'minor');
define('DISALLOW_FILE_MODS', false);
define('DISALLOW_FILE_EDIT', true);
define('FS_CHMOD_DIR', 0755);
define('FS_CHMOD_FILE', 0644);
define('WP_ALLOW_REPAIR', true);

/* Multisite */
define('WP_ALLOW_MULTISITE', false);

/* Content */
define('WP_POST_REVISIONS', 2);					// Can also be set to false
define('AUTOSAVE_INTERVAL', 60); 				// Time in seconds
define('EMPTY_TRASH_DAYS', 14); 				// Setting to 0 disables entirely, but all deletions skip the trash folder and are permanent.
define('MEDIA_TRASH', true );

/* Compression */
//define('COMPRESS_CSS',        true);
//define('COMPRESS_SCRIPTS',    true);
//define('ENFORCE_GZIP',        true);

/* Security Headers */
//header('X-Frame-Options: SAMEORIGIN');
//header('X-XSS-Protection: 1; mode=block');
//header('X-Content-Type-Options: nosniff');
//header('Referrer-Policy: no-referrer');
//header('Expect-CT enforce; max-age=3600');
//header('Content-Security-Policy: default-src \'self\' \'unsafe-inline\' \'unsafe-eval\' https: data:'); // Don't enable this unless you've researched and set a content policy.

/* Debug */
define('WP_DEBUG', false);
define('SCRIPT_DEBUG', false);					// Use dev versions of core JS and CSS files (only needed if you are modifying these core files)
define('WP_DEBUG_LOG', false);       		// Located in /wp-content/debug.log
define('WP_DEBUG_DISPLAY', false);    	// Displays logs on site
define('CONCATENATE_SCRIPTS', true);  	// Setting to False may fix java issues in dashboard only
define('SAVEQUERIES', false);        	 	// https://codex.wordpress.org/Editing_wp-config.php#Save_queries_for_analysis
//define('WP_ALLOW_REPAIR', true);      // http://${DOMAIN}/wp-admin/maint/repair.php  - Make sure to disable this once you're done. Anyone can trigger.

/* Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/* Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
