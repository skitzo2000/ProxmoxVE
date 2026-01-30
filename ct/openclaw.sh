#!/usr/bin/env bash
source <(curl -s https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/misc/build.func)
# Copyright (c) 2026 community-scripts ORG
# Author: skitzo2000
# License: MIT
# https://github.com/community-scripts/ProxmoxVE/raw/main/ct/openclaw.sh

APP="OpenClaw"
var_tags="${var_tags:-ai}"
var_cpu="${var_cpu:-2}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-20}"
var_os="${var_os:-ubuntu}"
var_version="${var_version:-24.04}"
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
	header_info
	check_container_storage
	check_container_resources

	msg_info "Updating base system"
	$STD apt update
	$STD apt upgrade -y
	msg_ok "Base system updated"

	msg_info "Updating Docker Engine"
	$STD apt install --only-upgrade -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx-plugin
	msg_ok "Docker Engine updated"

	msg_ok "Updated successfully!"
	exit
}

# Define the installation script URL
SCRIPT_URL="https://raw.githubusercontent.com/skitzo2000/ProxmoxVE/main/install/openclaw-install.sh"

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW} Access it using the following URL:${CL}"
echo -e "${TAB}${GATEWAY}${BGN}http://${IP}:18789${CL}"