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
echo "        Closing EngineScript in 5 seconds."
echo ""
echo "        Run again by typing enginescript in console."
echo ""
echo "============================================================="
echo ""
sleep 5
exit

# Cleanup
cd /usr/src
rm -rf *.tar.gz*
