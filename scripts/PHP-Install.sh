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

# Add PHP PPA Repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4F4EA0AAE5267A6C
sudo add-apt-repository -y ppa:ondrej/php

# Install PHP
sudo apt update && sudo apt upgrade -y
sudo apt install php7.2 php7.2-bcmath php7.2-cli php7.2-common php7.2-curl php7.2-fpm php7.2-gd php-geoip php-imagick php7.2-intl php7.2-json php7.2-mbstring php7.2-mysql php7.2-opcache php-pear php7.2-readline php7.2-soap php7.2-tidy php7.2-xml php7.2-xmlrpc php7.2-xsl php7.2-zip -y
sudo mkdir -p /etc/php/7.2/fpm/config-backups

# Backup existing php.ini
echo ""
echo ""
echo "Backing up existing php.ini. Backup can be found in /etc/php/7.2/fpm/config-backups"
sudo cp /etc/php/7.2/fpm/php.ini /etc/php/7.2/fpm/config-backups
sleep 3

# Retreive EngineScript php.ini
sudo wget sudo wget https://raw.githubusercontent.com/VisiStruct/EngineScript/master/php/php.ini -O /etc/php/7.2/fpm

# Restart Nginx & PHP
sudo service nginx restart
sudo service php7.2-fpm restart

echo ""
echo "============================================================="
echo ""
echo "        PHP ${PHP_VER} setup completed."
echo ""
echo "        Returning to main menu in 5 seconds..."
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
