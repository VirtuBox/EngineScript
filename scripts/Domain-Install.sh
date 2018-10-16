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
    echo "EngineScript should be executed as the root user."
    exit
fi

#----------------------------------------------------------------------------
# Main Script Start

# Intro Warning
echo ""
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-"
echo "|   Domain Creation                                   |"
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-"
echo ""
echo "Read the questions carefully and enter the proper response to each question."
echo ""
echo ""
echo "WARNING: Do not run this script on a site that already exists."
echo "If you do, things will break."
echo ""
echo ""
sleep 5

# Domain Input
echo "For domain name, enter just the domain without https:// or trailing /"
echo "note:   lowecase text only"
echo ""
echo "Examples:    yourdomain.com"
echo "             yourdomain.net"
echo ""
read -p "Enter Domain name: " DOMAIN
echo ""
echo "You entered:  ${DOMAIN}"
echo "SITE_URL=${DOMAIN}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo ""
echo ""
echo ""
echo ""
echo ""

# SSL Certificate Input
clear
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
clear
echo "----------------------------------------------------------------"
echo "Copy the entire Origin Certificate, then paste it into the input below."
echo "Be sure to include the entire script, including the BEGIN and END portions."
echo ""
echo  "Example:"
echo "-----BEGIN PRIVATE KEY-----"
echo "MIGHAgEAMBMGByqGSM49AgEGCCqgsM49AwEHBG0wawIBAQQgmO3MVO22TVWEdtfe"
echo "gjB+XbAknyDdwLhghL4GyBx9GTGhRANCAAQgC/LadElQyBWbysrjxa5AGL+KE/uf"
echo "MIGHAgEAMBMGByqGSM49AgEGCCqgsM49AwEHBG0wawIBAQQgmO3MVO22TVWEdtfe"
echo "gjB+XbAknyDdwLhghL4GyBx9GTGhRANCAAQgC/LadElQyBWbysrjxa5AGL+KE/uf"
echo "tIdf041YNreM35PLuYB3i8zgJNm99Tzx3ClhZ58FLdEWV+S2cfOsyGTt"
echo "-----END PRIVATE KEY-----"
echo ""
echo "Paste is usually done within an SSH client using either CTRL+SHIFT+V or right click."
echo "When finished, do not press enter. Input will close 2 seconds after paste."
echo ""
echo "Paste your Origin Certificate:"
IFS= read -d '' -n 1 ORIGIN_CERT
while IFS= read -d '' -n 1 -t 2 c
  do
    ORIGIN_CERT+=$c
  done

# Create Origin Certificate
sudo mkdir -p /etc/nginx/ssl/${DOMAIN}
sudo cat <<EOT >> /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.ocrt.pem
${ORIGIN_CERT}
EOT
echo "Origin Certificate set"
echo ""

# Private Key User Input
clear
echo "Copy the entire Private Key, then paste it into the input below."
echo ""
echo "Paste is usually done within an SSH client using either CTRL+SHIFT+V or right click."
echo "When finished, do not press enter. Input will close 2 seconds after paste."
echo ""
echo "Paste your Private Key:"
IFS= read -d '' -n 1 PRIVATE_KEY
while IFS= read -d '' -n 1 -t 2 c
  do
    PRIVATE_KEY+=$c
  done

# Create Private Key
sudo cat <<EOT >> /etc/nginx/ssl/${DOMAIN}/${DOMAIN}.pkey.pem
${PRIVATE_KEY}
EOT
echo "Private Key set"
echo ""
sleep 3

# Final Cloudflare SSL Steps
clear
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

# Domain Creation Variables
SDB="ESwp${RAND_CHAR2}"
SUSR="ESwp${RANDOM}${RANDOM}"
SPS="ESwp${RAND_CHAR2}${RAND_CHAR}${DT}"

# Domain Database Credentials
echo "DB=${SDB}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "USER=${SUSR}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "PSWD=${SPS}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo ""

source /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt
source /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "Randomly generated MySQL database credentials for ${SITE_URL}."
echo ""
sleep 2
sudo mysql -u root -p$MYSQL_RP -e "CREATE DATABASE ${DB};"
sudo mysql -u root -p$MYSQL_RP -e "CREATE USER ${USER}@'localhost' IDENTIFIED BY '${PSWD}';"
sudo mysql -u root -p$MYSQL_RP -e "GRANT index, select, insert, delete, update, create, drop, alter, create temporary tables, execute, lock tables, create view, show view, create routine, alter routine, trigger ON ${DB}.* TO ${USER}@'localhost'; FLUSH PRIVILEGES;"

sudo mkdir -p /var/www/${SITE_URL}/html
cd /var/www/${SITE_URL}/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sudo mv wordpress/* .
sudo rmdir /var/www/${SITE_URL}/html/wordpress
sudo rm -f /var/www/${SITE_URL}/html/wp-content/plugins/hello.php
sudo mkdir -p /var/www/${SITE_URL}/html/wp-content/uploads

# Create wp-config.php
sudo wget -O /var/www/${SITE_URL}/html/wp-config.php https://raw.githubusercontent.com/VisiStruct/EngineScript/master/misc/wp/wp-config.php
sudo sed -i "s|SEDWPDB|${DB}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDSALT|${WPSALT}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDWPUSER|${USER}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDWPPASS|${PSWD}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDPREFIX|${PREFIX}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDURL|${SITE_URL}|g" /var/www/${SITE_URL}/html/wp-config.php

# WP File Permissions
sudo find /var/www/${SITE_URL}/html/ -type d -exec chmod 755 {} \;
sudo find /var/www/${SITE_URL}/html/ -type f -exec chmod 644 {} \;
sudo chown -hR www-data:www-data /var/www/${SITE_URL}/html/

# Create Domain Vhost File
sudo wget -O /etc/nginx/sites-enabled/${SITE_URL}.conf https://raw.githubusercontent.com/VisiStruct/EngineScript/master/nginx/sites-enabled/yourdomain.com.conf
sudo sed -i "s|yourdomain.com|${SITE_URL}|g" /etc/nginx/sites-enabled/${SITE_URL}.conf

# Backup Dir Creation
sudo mkdir -p /home/EngineScript/user-data/config-backups/nginx/${SITE_URL}
sudo mkdir -p /home/EngineScript/user-data/site-backups/${SITE_URL}

# Create Backups
sudo cp -r /etc/nginx/sites-enabled/${SITE_URL}.conf /home/EngineScript/user-data/config-backups/nginx/${SITE_URL}/
sudo cp -r /etc/nginx/ssl/${SITE_URL} /home/EngineScript/user-data/ssl-backups/
sudo cp -r /var/www/${SITE_URL}/html/wp-config.php /home/EngineScript/user-data/site-backups/${SITE_URL}/

# Backups notice
clear
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-"
echo "|   Backups:                                           |"
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-"
echo "For your records:"
echo "-------------------------------------------------------"
echo "URL:                  ${SITE_URL}"
echo "Database:             ${DB}"
echo "User:                 ${USER}"
echo "Password:             ${PSWD}"
echo "MySQL Root User:      root"
echo "MySQL Root Password:  ${MYSQL_RP}"
echo ""
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=="
echo ""
echo "Origin Certificate and Private Key have been backed up to:"
echo "/home/EngineScript/user-data/ssl-backups/${SITE_URL}"
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=="
echo ""
echo "Domain Vhost .conf file backed up to:"
echo "/home/EngineScript/user-data/config-backups/nginx/${SITE_URL}"
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=="
echo ""
echo "WordPress wp-config.php file backed up to:"
echo "/home/EngineScript/user-data/site-backups/${SITE_URL}"
echo "-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-=="
echo ""
sleep 5

# Restart Services
sudo service nginx restart && sudo service php7.2-fpm restart

echo ""
echo "============================================================="
echo ""
echo "        Domain setup completed."
echo ""
echo "        Your domain should be available now at:"
echo "        https://${SITE_URL}"
echo ""
echo "        Returning to main menu in 5 seconds."
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
sudo rm -rf *.tar.gz*
