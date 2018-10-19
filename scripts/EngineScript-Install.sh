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

# Update Server

# Configure EngineScript Server
sudo bash /usr/lib/EngineScript/scripts/PHP-Install.sh
sudo bash /usr/lib/EngineScript/scripts/Nginx-Install.sh
sudo bash /usr/lib/EngineScript/scripts/MariaDB-Install.sh
sudo bash /usr/lib/EngineScript/scripts/Tools-Install.sh

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
sudo apt autoremove -y --purge
sudo apt autoclean -y
