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
    echo "ServerAdmin NGINX Auto-Installer should be executed as the root user."
    exit
fi
#----------------------------------------------------------------------------
# Main Script Start

# Add PHP PPA Repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
sudo apt update && sudo apt upgrade -y
sudo apt install php7.2 php7.2-bcmath php7.2-cli php7.2-common php7.2-curl php7.2-fpm php7.2-gd php-geoip php-imagick php7.2-intl php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php-pear php7.2-readline php7.2-soap php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip -y

# Backup existing php.ini
echo ""
echo ""
echo "Backing up existing php.ini. Backup can be found in /home/EngineScript/user-data/config-backups/php"
sudo cp -r /etc/php/7.2/fpm/php.ini /home/EngineScript/user-data/config-backups/php/
sleep 3

# Retreive EngineScript php.ini
echo "EngineScript should be executed as the root user."

# Restart Nginx & PHP
sudo service nginx restart
sudo service php7.2-fpm restart

echo ""
echo "============================================================="
echo ""
echo "        PHP ${PHP_VER} setup completed."
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
