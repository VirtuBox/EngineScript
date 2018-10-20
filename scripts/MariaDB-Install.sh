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

# Add MariaDB repository
# We're using Digital Ocean's NYC repo. You can find more at https://downloads.mariadb.org/
sudo apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
# MariaDB Xenial Repo
if [ "${UBUNTU_VER}" = xenial ];
  then
    sudo add-apt-repository -y 'deb [arch=amd64,arm64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu xenial main'
fi

# MariaDB Bionic Repo
if [ "${UBUNTU_VER}" = bionic ];
  then
    sudo add-apt-repository -y 'deb [arch=amd64,arm64,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.3/ubuntu bionic main'
fi

# MYSQL Variables
MYSQL_RPS="${RAND_CHAR24}"
echo "MYSQL_RP=${MYSQL_RPS}" > /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt
source /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt

# Install MariaDB
sudo apt update
sudo sh -c 'apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y mariadb-server mariadb-client'
sudo apt upgrade -y
sudo apt dist-upgrade -y

# MySQL Secure Installation Automated
sudo mysql_secure_installation <<EOF

y
${MYSQL_RP}
${MYSQL_RP}
y
y
y
y
EOF

# MySQL Login Details Display
echo ""
echo "Your MySQL Login Details:"
echo "  User: root"
echo "  Pass: ${MYSQL_RP}"
echo ""
echo "Your password has been stored in /home/EngineScript/user-data/mysql-credentials/mysqlrp.txt"
sleep 10

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
