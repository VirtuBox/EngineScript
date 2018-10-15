#!/usr/bin/env bash
#----------------------------------------------------------------------------
# EngineScript - High Performance LEMP WordPress Server Installation Tool
#----------------------------------------------------------------------------
# Website:     https://EngineScript.com
# GitHub:      https://github.com/VisiStruct/EngineScript
# Issues:      https://github.com/VisiStruct/EngineScript/issues
#
# Author:      VisiStruct
# Hire Us:     https://VisiStruct.com
# Based On:    https://github.com/VisiStruct/WordPress-LEMP-Server-Ubuntu
# License:     GPL v3.0
# OS:          Ubuntu 16.04 Xenial & Ubuntu 18.04 Biotic
#----------------------------------------------------------------------------

# Variables
source /usr/lib/EngineScript/misc/variables/variables

# Check current users ID. If user is not 0 (root), exit.
if [ "${EUID}" != 0 ];
  then
    echo "ServerAdmin NGINX Auto-Installer should be executed as the root user."
    exit
fi

#----------------------------------------------------------------------------
# Main Script Start

# Intro Warning
echo ""
echo "    Read the questions carefully and enter the proper response to each question."
echo ""
echo ""
echo ""
sleep 5

# Domain Input
echo "For domain name, enter just the domain without https:// or trailing /"
echo "Examples:    yourdomain.com"
echo "             yourdomain.net"
echo ""
read -p "Enter Domain name: " DOMAIN
echo ""
echo "You entered:  ${DOMAIN}"
echo ""
echo ""
echo ""
echo ""
echo ""

# Create Domain Vhost File
sudo cat <<EOT > /etc/nginx/conf.d/vhost/${DOMAIN}.conf
# VisiStruct's LEMP WordPress Server Config
# https://github.com/VisiStruct/LEMP-Server-Xenial-16.04
# https://VisiStruct.com - Orlando Web Design and Maintenance

server {
 listen 80;
 listen [::]:80;
 server_name ${DOMAIN}.com www.${DOMAIN};
 return 301 https://${DOMAIN}$request_uri;
}

server {
 listen 443 ssl http2;
 listen [::]:443 ssl http2;
 server_name ${DOMAIN} www.${DOMAIN};

 # SSL Certs
 ssl_certificate /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.ocrt.pem;
 ssl_certificate_key /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.pkey.pem;
 ssl_client_certificate /etc/nginx/ssl/cloudflare/origin-pull-ca.pem;
 ssl_dhparam /etc/nginx/ssl/dhparam.pem;

 # SSL Settings
 ssl_buffer_size 1369;
 ssl_ciphers [EECDH+ECDSA+AESGCM+AES128|EECDH+ECDSA+CHACHA20]:EECDH+ECDSA+AESGCM+AES256:EECDH+ECDSA+AES128+SHA:EECDH+ECDSA+AES256+SHA:[EECDH+aRSA+AESGCM+AES128|EECDH+aRSA+CHACHA20]:EECDH+aRSA+AESGCM+AES256:EECDH+aRSA+AES128+SHA:EECDH+aRSA+AES256+SHA:RSA+AES128+SHA:RSA+AES256+SHA:RSA+3DES;
 ssl_ecdh_curve X25519:P-256:P-384:P-224:P-521;
 ssl_prefer_server_ciphers on;
 ssl_protocols TLSv1.2 TLSv1.3;
 ssl_session_cache shared:SSL:10m;
 ssl_session_tickets off;
 ssl_session_timeout 60m;
 ssl_verify_client on;

 # SSL Early Data
 ssl_early_data off;
 #proxy_set_header Early-Data $ssl_early_data;

 # OCSP Stapling
 # fetch OCSP records from URL in ssl_certificate and cache them
 #resolver 8.8.8.8 8.8.4.4 valid=300s;
 #ssl_stapling on;
 #ssl_stapling_verify on;

 ## Verify chain of trust of OCSP response using Root CA and Intermediate certs
 #ssl_trusted_certificate /path/to/root_CA_cert_plus_intermediates;

 # HSTS (31536000 seconds = 1 year)
 add_header Strict-Transport-Security "max-age=31536000; includeSubdomains; preload";

 # Powered By Header
 #more_set_headers "Server : Nginx"
 more_set_headers "X-Powered-By : EngineScript | WordPress LEMP Server";

 # Security Headers
 # https://www.owasp.org/index.php/OWASP_Secure_Headers_Project#tab=Headers
 # X-Frame-Options set to DENY can cause various issues with WordPress core and plugins. Set to DENY at your own risk.
 more_set_headers "X-Content-Type-Options : nosniff";
 more_set_headers "X-Frame-Options : SAMEORIGIN";
 more_set_headers "X-XSS-Protection : 1; mode=block";

 # Referrer-Policy
 # https://scotthelme.co.uk/a-new-security-header-referrer-policy/
 more_set_headers "Referrer-Policy : same-origin";

 # Content-Security-Policy: https://developers.google.com/web/fundamentals/security/csp/
 #more_set_headers "Content-Security-Policy : default-src https: data: 'unsafe-inline' 'unsafe-eval' always";

 # Force Microsoft Edge Browser Engine
 # https://msdn.microsoft.com/en-us/library/ff955275(v=vs.85).aspx
 more_set_headers "X-UA-Compatible : IE=Edge";

 # X-Robots-Tag
 # https://yoast.com/x-robots-tag-play/
 #more_set_headers "X-Robots-Tag : none";

 root /var/www/${DOMAIN}/html;

 # Nginx Domain Error Log
 access_log off;
 #access_log /var/log/domains/${DOMAIN}.access.log main buffer=256k flush=5m;
 error_log /var/log/domains/${DOMAIN}.error.log error;

 # FastCGI_Cache Start
 set $skip_cache 0;

 # POST requests and urls with a query string should always go to PHP
 if ($request_method = POST) {
   set $skip_cache 1;
 }

 if ($query_string != "") {
   set $skip_cache 1;
 }

 # Page-based Cache Rules for Wordpress
 # Avoids the cache for users visiting specific WordPress pages. This also blocks WooCommerce and Sensei default page locations.
 if ($request_uri ~* "\?add-to-cart=|/addons.*|/cart.*|/checkout.*|/contact.*|/customer-dashboard.*|/feed.*|/my-account.*|/my-courses.*|/support.*|/wc-api.*|/wp-admin.*|/wp-json.*|[a-z0-9_-]+-sitemap([0-9]+)?.xml|index.php|sitemap(_index)?.xml|wp-.*.php|/xmlrpc.php") {
   set $skip_cache 1;
 }

 # Arg-based Cache Rules for Wordpress
 # Skip cache for WooCommerce query string
 if ($arg_add-to-cart != "" ) {
   set $skip_cache 1;
 }

 # Cookie-based Cache Rules for Wordpress
 # Avoids the cache for logged-in users or recent commenters. This also blocks WooCommerce and Easy Digital Downloads.
 if ($http_cookie ~* "comment_author|edd_items_in_cart|wc_session_cookie_HASH|woocommerce_cart_hash|woocommerce_items_in_cart|woocommerce_recently_viewed|wordpress_[a-f0-9]+|wordpress_logged_in|wordpress_no_cache|wp-postpass|wp_woocommerce_session_[^=]*=([^%]+)%7C|wptouch_switch_toogle") {
   set $skip_cache 1;
 }

 # PHP + WordPress Common
 include /etc/nginx/globals/phpwpcommon.conf;

 # Additional Includes
 include /etc/nginx/globals/cloudflare.conf;
 include /etc/nginx/globals/errorpages.conf;
 include /etc/nginx/globals/fileheaders.conf;
 include /etc/nginx/globals/wpsecurity.conf;

 # Google XML Sitemaps Plugin Rewrites
 #rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.xml$ "/index.php?xml_sitemap=params=$2" last;
 #rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.xml\.gz$ "/index.php?xml_sitemap=params=$2;zip=true" last;
 #rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.html$ "/index.php?xml_sitemap=params=$2;html=true" last;
 #rewrite ^/sitemap(-+([a-zA-Z0-9_-]+))?\.html.gz$ "/index.php?xml_sitemap=params=$2;html=true;zip=true" last;

 # Yoast SEO Plugin Rewrites
 location ~ ([^/]*)sitemap(.*)\.x(m|s)l$ {
   # This redirects sitemap.xml to /sitemap_index.xml
   rewrite ^/sitemap\.xml$ /sitemap_index.xml permanent;
   # This makes the XML sitemaps work
   rewrite ^/([a-z]+)?-?sitemap\.xsl$ /index.php?xsl=$1 last;
   rewrite ^/sitemap_index\.xml$ /index.php?sitemap=1 last;
   rewrite ^/([^/]+?)-sitemap([0-9]+)?\.xml$ /index.php?sitemap=$1&sitemap_n=$2 last;
   # News SEO
   #rewrite ^/news-sitemap\.xml$ /index.php?sitemap=wpseo_news last;
   # Local SEO
   #rewrite ^/locations\.kml$ /index.php?sitemap=wpseo_local_kml last;
   #rewrite ^/geo-sitemap\.xml$ /index.php?sitemap=wpseo_local last;
   # Video SEO
   #rewrite ^/video-sitemap\.xsl$ /index.php?xsl=video last;
 }

}

EOT
sudo mkdir -p /home/EngineScript/user-data/config-backups/nginx/${DOMAIN}
sudo cp -r /etc/nginx/conf.d/vhost/${DOMAIN}.conf /home/EngineScript/user-data/config-backups/nginx/${DOMAIN}/

# SSL Certificate Input
echo "Cloudflare SSL Certificate"
echo "----------------------------------------------------------------"
echo "You'll need to generate the certificate for your domain from within Cloudflare's control panel."
echo "Failure to enter the correct response will make your virtual host file incorrect."
echo ""
echo "Follow the steps below"
echo "----------------------------------------------------------------"
echo "  1.  Visit Cloudflare.com in your browser."
echo "  2.  Select your domain."
echo "  3.  Click on Crypto from the menu."
echo "  4.  Under the SSL, set to Full (Strict)."
echo "  5.  Under Origin Certificates, click Create Certificate."
echo "  6.  Choose ECDSA for private key type, then hit next."
echo ""
echo ""

# Origin Certificate User Input
echo "Copy the entire Origin Certificate, then paste it into the input below."
echo "Paste is usually done within an SSH client using either CTRL+SHIFT+V or right click."
echo "Input will close 2 seconds after paste."
echo ""
echo "Paste your Origin Certificate:"
IFS= read -d '' -n 1 ORIGIN_CERT
while IFS= read -d '' -n 1 -t 2 c
  do
    keyvariable+=$c
  done

# Create Origin Certificate
sudo mkdir -p /etc/nginx/ssl/${DOMAIN}
sudo cat <<EOT >> /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.ocrt.pem
${ORIGIN_CERT}
EOT
echo "Thanks! Origin Certificate set"
echo ""

# Private Key User Input
echo "Copy the entire Private Key, then paste it into the input below."
echo "Paste is usually done within an SSH client using either CTRL+SHIFT+V or right click."
echo "Input will close 2 seconds after paste."
echo ""
echo "Paste your Private Key:"
IFS= read -d '' -n 1 PRIVATE_KEY
while IFS= read -d '' -n 1 -t 2 c
  do
    keyvariable+=$c
  done

# Create Private Key
sudo mkdir -p /etc/nginx/ssl/${DOMAIN}
sudo cat <<EOT >> /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.pkey.pem
${PRIVATE_KEY}
EOT
echo "Thanks! Private Key set"
echo ""
sudo cp -r /etc/nginx/ssl/${DOMAIN} /home/EngineScript/user-data/ssl-backups/
echo "Origin Certificate and Private Key have also been backed up to /home/EngineScript/user-data/ssl-backups/${DOMAIN}"
sleep 3

# Final Cloudflare SSL Steps
echo ""
echo ""
echo "Click the OK button to leave the Create Certificate window."
echo "A bit further down the page, set the rest of the Cloudflare SSL options:"
echo "  1.  Set Always Use HTTPS to On."
echo "  2.  We recommend enabling HSTS. Turning off HSTS will make your site unreachable until the Max-Age time expires. This is a setting you want to set once and leave on forever."
echo "  3.  Set Authenticated Origin Pulls to On."
echo "  4.  Set Minimum TLS Version to TLS 1.2 or TLS 1.1, depending on whether you need to support much older browsers or other applications."
echo "  5.  Set Opportunistic Encryption to On."
echo "  6.  Set Onion Routing to On."
echo "  7.  Set TLS 1.3 to Enabled+0RTT."
echo "  8.  Set Automatic HTTPS Rewrites** to On."
echo ""
echo ""
while true;
  do
    read -p "When finished, enter y to continue to the next step: " y
      case $y in
        [Yy]* )
          echo "Let's continue";
          sleep 1;
          break
          ;;
        * ) echo "Please answer y";;
      esac
  done

# Download Wordpress

# Domain Creation Variables
WP_SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
DBS="ES${DOMAIN}WP"
DBUSERS="ES${RANDOM}WP${RANDOM}"
DBPASSS="ES${RANDOM}WP${DT}@%&${RAND_CHAR}"

# Domain Database Credentials
source /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt
source /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "WPDB=${DBS}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}
echo "WPUSER=${DBUSERS}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}
echo "WPPASS=${DBPASSS}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}
echo ""
echo "Randomly generated MySQL database credentials for ${DOMAIN}."
echo "Database: ${WPDB}"
echo "User:     ${WPUSER}"
echo "Password: ${WPPASS}"
echo ""
echo "These database credentials have also been backed up to /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt"

mysql -u root -p${MYSQL_RP} -e "CREATE USER ${WPUSER}@'localhost' IDENTIFIED BY '${WPPASS}';"
mysql -u root -p${MYSQL_RP} -e "GRANT index, select, insert, delete, update, create, drop, alter, create temporary tables, execute, lock tables, create view, show view, create routine, alter routine, trigger ON ${WPDB}.* TO ${WPUSER}@'localhost'; FLUSH PRIVILEGES;"

sudo mkdir -p /var/www/${DOMAIN}/html
cd /var/www/${DOMAIN}/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* .
sudo rmdir /var/www/${DOMAIN}/html/wordpress
sudo rm -f /var/www/${DOMAIN}/html/wp-content/plugins/hello.php
sudo mkdir -p /var/www/${DOMAIN}/html/wp-content/uploads

# Create wp-config.php
sudo cat <<EOT > /var/www/${DOMAIN}/html/wp-config.php
<?php

/* MySQL settings - You can get this info from your web host */
define('DB_NAME',			'${WPDB}');
define('DB_USER',			'${WPUSER}');
define('DB_PASSWORD',	'${WPPASS}');
define('DB_CHARSET',	'utf8');				// Don't change this if in doubt.
define('DB_HOST',			'localhost');		// Don't change this if in doubt.
define('DB_COLLATE',	'');						// Don't change this if in doubt.

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
define('WP_POST_REVISIONS', 2);			// Can also be set to false
define('AUTOSAVE_INTERVAL', 60);		// Time in seconds
define('EMPTY_TRASH_DAYS', 14);			// Setting to 0 disables entirely, but all deletions skip the trash folder and are permanent.
define('MEDIA_TRASH', true );

/* Compression */
//define('COMPRESS_CSS',			true);
//define('COMPRESS_SCRIPTS',	true);
//define('ENFORCE_GZIP',			true);

/* Security Headers */
//header('X-Frame-Options: SAMEORIGIN');
//header('X-XSS-Protection: 1; mode=block');
//header('X-Content-Type-Options: nosniff');
//header('Referrer-Policy: no-referrer');
//header('Expect-CT enforce; max-age=3600');
//header('Content-Security-Policy: default-src \'self\' \'unsafe-inline\' \'unsafe-eval\' https: data:'); // Don't enable this unless you've researched and set a content policy.

/* Debug */
define('WP_DEBUG', false);
define('SCRIPT_DEBUG', false);				// Use dev versions of core JS and CSS files (only needed if you are modifying these core files)
define('WP_DEBUG_LOG', false);				// Located in /wp-content/debug.log
define('WP_DEBUG_DISPLAY', false);		// Displays logs on site
define('CONCATENATE_SCRIPTS', true);	// Setting to False may fix java issues in dashboard only
define('SAVEQUERIES', false);					// https://codex.wordpress.org/Editing_wp-config.php#Save_queries_for_analysis
//define('WP_ALLOW_REPAIR', true);		// http://${DOMAIN}/wp-admin/maint/repair.php  - Make sure to disable this once you're done. Anyone can trigger.

/* Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/* Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');

EOT

sudo mkdir -p /home/EngineScript/user-data/site-backups/${DOMAIN}
sudo cp -r /var/www/${DOMAIN}/html/wp-config.php /home/EngineScript/user-data/site-backups/${DOMAIN}/
echo ""

sudo cp -r /etc/nginx/ssl/${DOMAIN} /home/EngineScript/user-data/ssl-backups/
echo "Origin Certificate and Private Key have also been backed up to /home/EngineScript/user-data/ssl-backups/${DOMAIN}"
sleep 3

sudo find /var/www/${DOMAIN}/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/${DOMAIN}/html/ -type f -exec chmod 644 {} \;
sudo chown -hR www-data:www-data /var/www/${DOMAIN}/html/

echo ""
echo "============================================================="
echo ""
echo "        Domain setup completed."
echo ""
echo "        Returning to main menu in 5 seconds."
echo ""
echo "============================================================="
echo ""
sleep 5


# Cleanup
cd /usr/src
rm -rf *.tar.gz*
