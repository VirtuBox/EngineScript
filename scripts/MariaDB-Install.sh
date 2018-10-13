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
#
#----------------------------------------------------------------------------

# Variables
CPU_COUNT="$(nproc --all)"
CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IP_ADDRESS="$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')"
MARIADB_VER="10.3"
NGINX_HEADER_VER="0.33"
NGINX_PURGE_VER="2.5"
NGINX_VER="1.15.5"
OPENSSL_VER="1.1.1"
PCRE_VER="8.42"
PHPMYADMIN_VER="4.8.3"
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

# Add MariaDB repository
# We're using Digital Ocean's NYC repo. You can find more at https://downloads.mariadb.org/
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
# MariaDB Xenial Repo
if [ "${UBUNTU_VER}" = xenial ];
  then
    sudo add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu xenial main'
fi

# MariaDB Biotic Repo
if [ "${UBUNTU_VER}" = biotic ];
  then
    sudo add-apt-repository -y 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu biotic main'
fi

# Install MariaDB
sudo apt update
sudo apt install mariadb-server mariadb-client -y
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y

# MySQL Secure installation
# Answers no to change password, since user just set it. Then answers yes to all other questions.
mysql_secure_installation

echo ""
echo "============================================================="
echo ""
echo "        MariaDB setup completed."
echo ""
echo "============================================================="
echo ""
sleep 5

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
