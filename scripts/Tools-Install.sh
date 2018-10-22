#!/usr/bin/env bash
#----------------------------------------------------------------------------
# EngineScript - High Performance LEMP WordPress Server Installation Tool
#----------------------------------------------------------------------------
# Website:       https://EngineScript.com
# GitHub:        https://github.com/VisiStruct/EngineScript
# Author:        VisiStruct
# License:       GPL v3.0
# OS:            Ubuntu 16.04 Xenial & Ubuntu 18.04 Bionic
#----------------------------------------------------------------------------
# Buy a VPS from Digital Ocean:       https://m.do.co/c/e57cc8492285
#
#
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

# phpMyAdmin Install
cd /usr/src
sudo wget https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VER}/phpMyAdmin-${PHPMYADMIN_VER}-all-languages.tar.gz && sudo tar -xzvf phpMyAdmin-${PHPMYADMIN_VER}-all-languages.tar.gz
cp -a /usr/src/phpMyAdmin-${PHPMYADMIN_VER}-all-languages/. /usr/share/phpmyadmin
sudo ln -s /usr/share/phpmyadmin /var/www/admin/tools/phpmyadmin
echo ""
echo "============================================================="
echo ""
echo "        phpMyAdmin installed."
echo ""
echo "        Point your browser to http://${IP_ADDRESS}/tools/phpmyadmin."
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
echo "        Point your browser to http://${IP_ADDRESS}/tools/phpinfo/phpinfo.php."
echo ""
echo "============================================================="
echo ""
sleep 5

# MYSQLTuner Install
sudo mkdir -p /usr/lib/mysqltuner
sudo wget http://mysqltuner.pl/ -O /usr/lib/mysqltuner/mysqltuner.pl
sudo wget -O /usr/lib/mysqltuner/basic_passwords.txt https://raw.githubusercontent.com/major/MySQLTuner-perl/master/basic_passwords.txt
sudo wget -O /usr/lib/mysqltuner/vulnerabilities.csv https://raw.githubusercontent.com/major/MySQLTuner-perl/master/vulnerabilities.csv
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

# Tuning-Primer Install
sudo mkdir -p /usr/lib/tuning-primer
wget https://raw.githubusercontent.com/mattiabasone/tuning-primer/master/tuning-primer.sh -O /usr/lib/tuning-primer/tuning-primer.sh
sudo chmod 755 /usr/lib/tuning-primer/tuning-primer.sh
echo ""
echo "============================================================="
echo ""
echo "        Tuning-Primer installed."
echo ""
echo "        To run Tuning-Primer, type bash /usr/lib/tuning-primer/tuning-primer.sh"
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
echo "        gixy /etc/nginx/sites-enabled/yourdomain.com.conf"
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
