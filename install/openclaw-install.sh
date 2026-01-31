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
  ca-certificates \
  gnupg \
  wget
msg_ok "Installed Dependencies"

msg_info "Installing Node.js ≥22"
NODEJS_VERSION=$(curl -s https://nodejs.org/dist/latest/ | grep -oP 'v\d+\.\d+\.\d+' | head -1)
if ! command -v node &> /dev/null || [ "$(node -v | grep -oP '\d+' | head -1)" -lt 22 ]; then
  curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
  $STD apt-get install -y nodejs
else
  msg_ok "Node.js $(node -v) already installed"
fi
msg_ok "Installed Node.js"

msg_info "Enabling pnpm"
$STD corepack enable
$STD pnpm --version > /dev/null 2>&1
msg_ok "pnpm enabled"

DOCKER_LATEST_VERSION=$(get_latest_github_release "moby/moby")

msg_info "Installing Docker $DOCKER_LATEST_VERSION (with Compose, Buildx)"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -fsSL https://get.docker.com)
msg_ok "Installed Docker $DOCKER_LATEST_VERSION"

msg_info "Installing OpenClaw"
mkdir -p /opt/openclaw
cd /opt/openclaw
$STD git clone https://github.com/openclaw/openclaw.git .

msg_info "Running OpenClaw Docker setup with interactive wizard"
msg_info "You will now be guided through the onboarding process"
msg_info "Follow the prompts to:"
msg_info "  • Select your AI model (Claude, GPT, etc.)"
msg_info "  • Configure messaging channels (WhatsApp, Telegram, Discord, etc.)"
msg_info "  • Set up your workspace"
msg_info ""
chmod +x ./docker-setup.sh
./docker-setup.sh

msg_ok "Installed OpenClaw"

msg_info "OpenClaw Setup Complete!"
msg_info "Your Gateway is running at http://127.0.0.1:18789/"
msg_info ""
msg_info "To add more channels later:"
msg_info "  docker compose run --rm openclaw-cli channels login"
msg_info ""
msg_info "To view configuration:"
msg_info "  cat /opt/openclaw/.env"
msg_info ""
msg_info "Configuration stored at: ~/.openclaw/"
msg_ok "Installation finished successfully"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"