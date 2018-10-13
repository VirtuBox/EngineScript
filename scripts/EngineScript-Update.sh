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

# Remove Old EngineScript Files
sudo rm -rf /usr/lib/EngineScript

# Retrieve Latest EngineScript
cd /usr/lib/
git clone https://github.com/VisiStruct/EngineScript.git

echo ""
echo "============================================================="
echo ""
echo "        EngineScript updated."
echo ""
echo "        Closing EngineScript in 10 seconds."
echo ""
echo "        Rerun EngineScript by typing enginescript in console."
echo ""
echo "============================================================="
echo ""
sleep 10

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
