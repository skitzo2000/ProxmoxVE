#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2026 community-scripts ORG
# Author: YourName
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/ct/openclaw.sh

function header_info {
  clear
  qv "OpenClaw"
}
header_info
echo -e "Loading..."
APP="OpenClaw"
VAR_DISK="20"
VAR_CPU="2"
VAR_RAM="4096"
VAR_OS="ubuntu"
VAR_VERSION="24.04"
NSAPP=$(echo ${APP,,} | tr -d ' ')

# Define the installation script URL (For testing, you would point this to your raw gist/repo)
# In a PR, this would be: https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/install/openclaw-install.sh
SCRIPT_URL="https://raw.githubusercontent.com/skitzo200/ProxmoxVE/main/install/openclaw-install.sh"

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:18789${CL}"