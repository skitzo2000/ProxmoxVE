#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: skitzo2000
# License: MIT | https://github.com/community-scripts/ProxmoxVE/raw/main/LICENSE
# Source: https://github.com/openclaw/openclaw

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt-get install -y \
  curl \
  git \
  mc \
  sudo \
  ca-certificates
msg_ok "Installed Dependencies"

msg_info "Installing Docker"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >$DOCKER_CONFIG_PATH
$STD sh <(curl -fsSL https://get.docker.com)
systemctl enable -q --now docker
msg_ok "Installed Docker"

msg_info "Installing OpenClaw"
mkdir -p /opt/openclaw
cd /opt/openclaw
$STD git clone https://github.com/openclaw/openclaw.git .

if [ -f "env.example" ]; then
  cp env.example .env
fi

if [ -f "docker-compose.yml" ] || [ -f "compose.yml" ]; then
  $STD docker compose pull
  $STD docker compose up -d
else
  msg_error "No docker-compose.yml or compose.yml found in repository"
  exit 1
fi
msg_ok "Installed OpenClaw"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"