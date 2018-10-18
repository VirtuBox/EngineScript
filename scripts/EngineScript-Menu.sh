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

# Main Menu
while true
  do
    clear
    echo ""
    echo ""
    echo "==============================================================="
    echo "EngineScript - Automated WordPress LEMP Server Installation"
    echo "==============================================================="
    echo ""
    echo "EngineScript is an automated, high-performance WordPress LEMP server installation tool."
    echo ""
    echo "To learn more about EngineScript, visit:"
    echo "https://github.com/VisiStruct/EngineScript"
    echo ""
    echo "To read the step-by-step tutorial that powers EngineScript, visit:"
    echo "https://github.com/VisiStruct/WordPress-LEMP-Server-Ubuntu"
    echo ""
    echo "EngineScript Requires:"
    echo "  - Ubuntu 16.04 Xenial or 18.04 Bionic"
    echo "  - Cloudflare"
    echo "  - 15 minutes of your time"
    echo ""
    echo "Ready to get started?"
    echo ""
    echo "Step 1 - Select option 1. Server will automatically restart at end."
    echo "Step 2 - After restart, type EngineScript to open EngineScript again."
    echo "Step 3 - Install EngineScript option 2."
    echo "Step 4 - Configure a new domain on the server by choosing option"
    echo ""
    echo ""
    echo "---------------------------------------------------------------"
    echo ""
    echo "What would you like to do?"
    echo ""
    PS3='Please enter your choice: '
    options=("Setup EngineScript WordPress LEMP Server (Installs Nginx, PHP, MariaDB, and Tools)" "Configure New Domain" "Update EngineScript" "Update Existing Domain Vhost File" "Update Nginx" "Update PHP" "Update MariaDB" "Update Server Management Tools" "Exit EngineScript")
    select opt in "${options[@]}"
    do
      case $opt in
        "Setup EngineScript WordPress LEMP Server (Installs Nginx, PHP, MariaDB, and Tools)")
          sudo bash /usr/lib/EngineScript/scripts/EngineScript-Install.sh
          break
          ;;
        "Configure New Domain")
          sudo bash /usr/lib/EngineScript/scripts/Domain-Install.sh
          break
          ;;
        "Update EngineScript")
          sudo bash /usr/lib/EngineScript/scripts/EngineScript-Update.sh
          break
          ;;
        "Update Existing Domain Vhost File")
          sudo bash /usr/lib/EngineScript/scripts/Domain-Install.sh
          break
          ;;
        "Update Nginx")
          sudo bash /usr/lib/EngineScript/scripts/Nginx-Install.sh
          break
          ;;
        "Update PHP")
          sudo bash /usr/lib/EngineScript/scripts/PHP-Install.sh
          break
          ;;
        "Update MariaDB")
          sudo bash /usr/lib/EngineScript/scripts/MariaDB-Install.sh
          break
          ;;
        "Update Server Management Tools")
          sudo bash /usr/lib/EngineScript/scripts/Tools-Install.sh
          break
          ;;
        "Exit EngineScript")
          exit
          ;;
        *) echo invalid option;;
      esac
    done
  done
