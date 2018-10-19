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
    echo "EngineScript should be executed as the root user."
    exit
fi

#----------------------------------------------------------------------------
# Main Script Start

# Reboot Warning
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

# Install server tools needed for script
sudo apt update
sudo apt install software-properties-common python-software-properties -y

# Set Time Zone
sudo dpkg-reconfigure tzdata

# Add Repositories
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/ppa
sudo add-apt-repository -y ppa:maxmind/ppa
sudo add-apt-repository -y ppa:jonathonf/gcc-8.1
sudo add-apt-repository -y ppa:jonathonf/gcc
#sudo add-apt-repository "deb http://archive.canonical.com/ubuntu ${UBUNTU_VER} partner"

# Update server and install dependencies
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt remove --purge mysql-server mysql-client mysql-common apache2* php5* nginx nginx-extras -y
sudo rm -rf /var/lib/mysql
sudo apt install autotools-dev axel bash-completion bc build-essential ccache checkinstall curl debhelper dh-systemd dos2unix gcc gcc-8 git glances g++-8 g++-8-multilib htop imagemagick libatomic-ops-dev libbsd-dev libbz2-1.0 libbz2-dev libbz2-ocaml libbz2-ocaml-dev libcurl4-openssl-dev libexpat-dev libgd-dev libgeoip-dev libgmp-dev libgoogle-perftools-dev libjemalloc-dev libjemalloc1 libluajit-5.1-common libluajit-5.1-dev libmcrypt-dev libmcrypt4 libmhash-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libreadline-dev libssl-dev libtidy-dev libtool libxml2 libxml2-dev libxslt1-dev make mcrypt mlocate nano openssl perl pigz po-debconf pwgen python-jinja2 python-markupsafe python-pip python-psutil re2c ruby-dev software-properties-common sudo tar tree ufw unzip webp wget zip zlib1g zlib1g-dbg zlib1g-dev zlibc -y

# Cleanup
sudo apt autoremove -y
sudo apt autoclean -y

# GCC
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 80 --slave /usr/bin/g++ g++ /usr/bin/g++-8

# Jemalloc
touch /etc/ld.so.preload
echo "/usr/lib/x86_64-linux-gnu/libjemalloc.so" | sudo tee --append /etc/ld.so.preload

# PCRE
cd /usr/src
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

# Cloudflare zlib Fork
sudo rm -rf /usr/src/zlib-cf
cd /usr/src
sudo git clone https://github.com/cloudflare/zlib.git -b gcc.amd64 zlib-cf
cd zlib-cf
sudo make -f Makefile.in distclean
./configure --prefix=/usr/local/zlib-cf
sudo make
sudo make install

# UFW
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443
echo "y" | sudo ufw enable

# Official zlib Download\
# Just in-case the user wants to use this instead of zlib-cf
cd /usr/src/
sudo wget https://www.zlib.net/zlib-${ZLIB_VER}.tar.gz && sudo tar xzvf zlib-${ZLIB_VER}.tar.gz

# Set Editor
export EDITOR=/bin/nano

# Optimizing HTTP/2 and TCP Fast Open
# https://blog.cloudflare.com/http-2-prioritization-with-nginx/
cat <<EOT >> /etc/sysctl.conf
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_notsent_lowat = 16384
net.ipv4.tcp_fastopen = 3
EOT

# EngineScript Git Clone
sudo rm -rf /usr/lib/EngineScript
cd /usr/lib/
git clone https://github.com/VisiStruct/EngineScript.git
echo ""
echo "============================================================="
echo ""
echo "        EngineScript installed to:"
echo ""
echo "        /usr/lib/EngineScript"
echo ""
echo "============================================================="
sleep 2

# Alias Creation
cat <<EOT >> /root/.bashrc
alias enginescript="sudo bash /usr/lib/EngineScript/scripts/EngineScript-Menu.sh"
alias esmenu="sudo bash /usr/lib/EngineScript/scripts/EngineScript-Menu.sh"
alias esrestart="sudo service nginx restart && service php7.2-fpm restart"
alias esupdate="sudo apt update && sudo apt upgrade && sudo apt dist-upgrade"
EOT

# EngineScript Home Directory Creation
mkdir -p /home/EngineScript/user-data/config-backups/nginx
mkdir -p /home/EngineScript/user-data/config-backups/php
mkdir -p /home/EngineScript/user-data/mysql-credentials
mkdir -p /home/EngineScript/user-data/site-backups
mkdir -p /home/EngineScript/user-data/ssl-backups

echo "============================================================="
echo ""
echo ""
echo "        Server needs to reboot."
echo ""
echo "        Enter command enginescript after reboot to continue."
echo ""
echo "============================================================="
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
