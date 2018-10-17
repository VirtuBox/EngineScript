#!/usr/bin/env bash
#----------------------------------------------------------------------------
# EngineScript - High Performance LEMP WordPress Server Installation Tool
#----------------------------------------------------------------------------
# Website:     https://EngineScript.com
# GitHub:      https://github.com/VisiStruct/EngineScript
# Author:      VisiStruct
# License:     GPL v3.0
# OS:          Ubuntu 16.04 Xenial & Ubuntu 18.04 Bionic
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
echo "
-----BEGIN CERTIFICATE-----
MIIDLTCCAtKgAwIBAgIUW5cWYntbJ7+P71lMCaRBAdms0uswCgYIKoZIzj0EAwIw
gY8xCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1T
YW4gRnJhbmNpc2NvMRkwFwYDVQQKExBDbG91ZEZsYXJlLCBJbmMuMTgwNgYDVQQL
Ey9DbG91ZEZsYXJlIE9yaWdpbiBTU0wgRUNDIENlcnRpZmljYXRlIEF1dGhvcml0
eTAeFw0xODEwMTQwNjAwMDBaFw0zMzEwMTAwNjAwMDBaMGIxGTAXBgNVBAoTEENs
b3VkRmxhcmUsIEluYy4xHTAbBgNVBAsTFENsb3VkRmxhcmUgT3JpZ2luIENBMSYw
JAYDVQQDEx1DbG91ZEZsYXJlIE9yaWdpbiBDZXJ0aWZpY2F0ZTBZMBMGByqGSM49
AgEGCCqGSM49AwEHA0IABCAL8toNaVDIFZvKyuPFrkAYv4oT+5+0h1/TjVg2t4zf
k8u5gHeLzOAk2b31PPHcKWFnnwUt0Ra/5LZx86zIZO2jggE2MIIBMjAOBgNVHQ8B
Af8EBAMCBaAwHQYDVR0lBBYwFAYIKwYBBQUHAwIGCCsGAQUFBwMBMAwGA1UdEwEB
/wQCMAAwHQYDVR0OBBYEFOYgNf/vNY2AWEPhXBWiZShfyX43MB8GA1UdIwQYMBaA
FIUwXTsqcNTt1ZJnB/3rObQaDjinMEQGCCsGAQUFBwEBBDgwNjA0BggrBgEFBQcw
AYYoaHR0cDovL29jc3AuY2xvdWRmbGFyZS5jb20vb3JpZ2luX2VjY19jYTAvBgNV
HREEKDAmghIqLmVuZ2luZXNjcmlwdC5jb22CEGVuZ2luZXNjcmlwdC5jb20wPAYD
VR0fBDUwMzAxoC+gLYYraHR0cDovL2NybC5jbG91ZGZsYXJlLmNvbS9vcmlnaW5f
ZWNjX2NhLmNybDAKBggqhkjOPQQDAgNJADBGAiEA2wxm5NARdNd8wxriFEkX0l+3
ywzgZyb9bCoCwKAdp0gCIQD3uEESW8g8uWph+JxalVrlm49BZ9DJiQM6R+J7bbJz
sg==
-----END CERTIFICATE-----"
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
echo "Example:

-----BEGIN PRIVATE KEY-----
MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgmO3MVO22TVWEdtfe
gjB+XbAknyDdwLrweL4GyBx9GTGhRANCAAQgC/LaDWlQyBWbysrjxa5AGL+KE/uf
tIdf041YNreM35PLuYB3i8zgJNm99Tzx3ClhZ58FLdEWv+S2cfOsyGTt
-----END PRIVATE KEY-----


"
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
echo ""
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
echo "USR=${SUSR}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "PSWD=${SPS}" >> /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo ""

source /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt
source /home/EngineScript/user-data/mysql-credentials/${DOMAIN}.txt
echo "Randomly generated MySQL database credentials for ${SITE_URL}."
echo ""
sleep 2
sudo mysql -u root -p$MYSQL_RP -e "CREATE DATABASE ${DB};"
sudo mysql -u root -p$MYSQL_RP -e "CREATE USER ${USR}@'localhost' IDENTIFIED BY '${PSWD}';"
sudo mysql -u root -p$MYSQL_RP -e "GRANT index, select, insert, delete, update, create, drop, alter, create temporary tables, execute, lock tables, create view, show view, create routine, alter routine, trigger ON ${DB}.* TO ${USR}@'localhost'; FLUSH PRIVILEGES;"

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
sudo sed -i "s|SEDWPUSER|${USR}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDWPPASS|${PSWD}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDPREFIX|${PREFIX}|g" /var/www/${SITE_URL}/html/wp-config.php
sudo sed -i "s|SEDURL|${SITE_URL}|g" /var/www/${SITE_URL}/html/wp-config.php

# WP Salt Creation
SALT=$(curl -L https://api.wordpress.org/secret-key/1.1/salt/)
STRING='put your unique phrase here'
printf '%s\n' "g/$STRING/d" a "$SALT" . w | ed -s /var/www/${SITE_URL}/html/wp-config.php

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
echo "
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-
|   Backups:                                          |
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-
For your records:
-------------------------------------------------------
URL:                  ${SITE_URL}
Database:             ${DB}
User:                 ${USR}
Password:             ${PSWD}
MySQL Root User:      root
MySQL Root Password:  ${MYSQL_RP}

-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-

MySQL Root and Domain login credentials backed up to:
/home/EngineScript/user-data/mysql-credentials/${SITE_URL}
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-


Origin Certificate and Private Key have been backed up to:
/home/EngineScript/user-data/ssl-backups/${SITE_URL}
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-

Domain Vhost .conf file backed up to:
/home/EngineScript/user-data/config-backups/nginx/${SITE_URL}
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-

WordPress wp-config.php file backed up to:
/home/EngineScript/user-data/site-backups/${SITE_URL}
-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-==-

"
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
