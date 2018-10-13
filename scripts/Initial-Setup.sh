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

echo ""
echo "============================================================="
echo ""
echo "        ##################################"
echo "        |           ATTENTIION           |"
echo "        ##################################"
echo ""
echo "        Server needs to be rebooted at the end of this script."
echo "        Enter command enginescript after reboot to continue."
echo ""
echo "        Script will continue in 5 seconds..."
echo ""
echo "============================================================="
echo ""
echo ""
echo ""
sleep 5

# Update server and install dependencies
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt install autotools-dev bc build-essential checkinstall ccache curl debhelper dh-systemd dos2unix gcc git htop imagemagick libatomic-ops-dev libbz2-dev libcurl4-openssl-dev libexpat-dev libgd-dev libgeoip-dev libgmp-dev libgoogle-perftools-dev libluajit-5.1-common libluajit-5.1-dev libmhash-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libssl-dev libxml2 libxml2-dev libxslt1-dev make nano openssl perl po-debconf python-pip ruby-dev software-properties-common sudo tar unzip webp wget zip zlibc zlib1g zlib1g-dbg zlib1g-dev -y

# Remove stuff we don't want
sudo apt remove --purge mysql-server mysql-client mysql-common apache2* php5* nginx nginx-extras -y
sudo apt autoremove -y
sudo apt autoclean -y
sudo rm -rf /var/lib/mysql

# Git Clone
sudo rm -rf /usr/lib/EngineScript
cd /usr/lib/
git clone https://github.com/VisiStruct/EngineScript.git
echo ""
echo "============================================================="
echo ""
echo "        EngineScript installation completed."
echo ""
echo "        EngineScript is located in /usr/lib/EngineScript"
echo ""
echo "============================================================="
sleep 5

# Alias Creation

cat <<EOT >> /root/.bashrc
alias enginescript="sudo bash /usr/lib/EngineScript/scripts/EngineScript-Menu.sh"
alias esmenu="sudo bash /usr/lib/EngineScript/scripts/EngineScript-Menu.sh"
alias esrestart="sudo service nginx restart && service php7.2-fpm restart"
alias esupdate="sudo apt update && sudo apt upgrade && sudo apt dist-upgrade"
EOT

# GCC
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/ppa
sudo add-apt-repository -y ppa:jonathonf/gcc-8.1
sudo add-apt-repository -y ppa:jonathonf/gcc
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt install gcc-8 g++-8 -y
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8
echo ""
echo "============================================================="
echo ""
echo "        GCC installation completed."
echo ""
echo "        Jemalloc installation will begin in 3 seconds."
echo ""
echo "============================================================="
echo ""
sleep 3

# PCRE
sudo wget https://ftp.pcre.org/pub/pcre/pcre-8.42.tar.gz && sudo tar xzvf pcre-8.42.tar.gz
cd /usr/src/pcre-8.42
./configure \
  --prefix=/usr \
  --enable-utf8 \
  --enable-unicode-properties \
  --enable-pcre16 \
  --enable-pcre32 \
  --enable-pcregrep-libz \
  --enable-pcregrep-libbz2 \
  --enable-pcretest-libreadline \
  --enable-jit

sudo make -j ${CPU_COUNT}
sudo make install
mv -v /usr/lib/libpcre.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libpcre.so) /usr/lib/libpcre.so
echo ""
echo "============================================================="
echo ""
echo "        PCRE installation completed."
echo ""
echo "============================================================="
sleep 3

# Jemalloc
sudo apt install libjemalloc1 libjemalloc-dev
touch /etc/ld.so.preload
echo "/usr/lib/x86_64-linux-gnu/libjemalloc.so" | sudo tee --append /etc/ld.so.preload
echo ""
echo "============================================================="
echo ""
echo "        Jemmalloc installation completed."
echo ""
echo "        Server needs to reboot to enable Jemalloc."
echo ""
echo "============================================================="
echo ""
sleep 2
echo "        Server will reboot in 10 seconds..."
echo ""
sleep 5
echo "        Server will reboot in 5 seconds..."
echo ""
sleep 5
echo "        Server rebooting now..."

# Cleanup
cd /usr/src
rm -rf *.tar.gz*


shutdown -r now
