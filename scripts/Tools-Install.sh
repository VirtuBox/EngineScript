#!/usr/bin/env bash
#----------------------------------------------------------------------------
# EngineScript - High Performance LEMP WordPress Server Installation Tool
#----------------------------------------------------------------------------
# Author:      VisiStruct
# Hire Us:     https://VisiStruct.com
# Website:     https://EngineScript.com
# GitHub:      https://github.com/VisiStruct/EngineScript
# Issues:      https://github.com/VisiStruct/EngineScript/issues
# Based On:    https://github.com/VisiStruct/WordPress-LEMP-Server-Ubuntu
# License:     GPL v3.0
# OS:          Ubuntu 16.04 Xenial & Ubuntu 18.04 Biotic
#
#----------------------------------------------------------------------------

# Variables
CPU_COUNT="$(nproc --all)"
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IP_ADDRESS="$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')"
NGINX_VER="1.15.5"
NGINX_HEADER_VER="0.33"
NGINX_PURGE_VER="2.5"
OPENSSL_VER="1.1.1"
PCRE_VER="8.42"
PHP_VER="7.2"
MARIADB_VER="10.3"
UBUNTU_VER="$(lsb_release -sc)"
ZLIB_VER="1.2.11"

# Check current users ID. If user is not 0 (root), exit.
if [ "${EUID}" != 0 ];
  then
    echo "ServerAdmin NGINX Auto-Installer should be executed as the root user."
    exit
fi

#----------------------------------------------------------------------------
# Main Script Start


# phpMyAdmin Install
sudo apt install phpmyadmin -y
sudo update-rc.d -f apache2 remove
sudo ln -s /usr/share/phpmyadmin /var/www/admin/tools/phpmyadmin
echo ""
echo "============================================================="
echo ""
echo "        phpMyAdmin installed."
echo ""
echo "        Point your browser to http://${IP_ADDRESS}/admin/tools/phpmyadmin."
echo ""
echo "============================================================="
echo ""
sleep 5

# PHPinfo Install
sudo mkdir -p /var/www/admin/tools/phpinfo
sudo echo "<?php phpinfo(); ?>" > /var/www/admin/tools/phpinfo/phpinfo.php
echo ""
echo "============================================================="
echo ""
echo "        phpinfo.php installed."
echo ""
echo "        Point your browser to http://${IP_ADDRESS}/admin/tools/phpinfo/phpinfo.php."
echo ""
echo "============================================================="
echo ""
sleep 5

# MYSQLTuner Install
sudo mkdir -p /usr/lib/mysqltuner
cd /usr/lib/mysqltuner
sudo wget http://mysqltuner.pl/ -O mysqltuner.pl
sudo wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt -O basic_passwords.txt
sudo wget https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv -O vulnerabilities.csv
echo ""
echo "============================================================="
echo ""
echo "        MySQLTuner installed."
echo ""
echo "        To run MySQLTuner, type perl /usr/lib/mysqltuner/mysqltuner.pl"
echo ""
echo "============================================================="
echo ""
sleep 5

# Install WPScan
sudo gem install wpscan
echo ""
echo "============================================================="
echo ""
echo "        WPScan installed."
echo ""
echo "        To run a scan of your site that includes checks for vulnerable themes and plugins:"
echo "        wpscan --url https://yourdomain.com --enumerate"
echo ""
echo "============================================================="
echo ""
sleep 5

# Install GIXY
sudo pip install --upgrade pip
sudo pip install gixy
echo ""
echo "============================================================="
echo ""
echo "        GIXY installed."
echo ""
echo "        To run a scan of your Nginx configuration:"
echo "        gixy /etc/nginx/nginx.conf"
echo "        gixy /etc/nginx/conf.d/yourdomain.com.conf"
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
