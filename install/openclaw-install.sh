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
if ! command -v node &> /dev/null || [ "$(node -v | cut -d'v' -f2 | cut -d'.' -f1)" -lt 22 ]; then
  $STD curl -fsSL https://deb.nodesource.com/setup_22.x | bash -
  $STD apt-get install -y nodejs
fi
msg_ok "Installed Node.js $(node -v)"

msg_info "Enabling pnpm"
$STD corepack enable
$STD corepack prepare pnpm@latest --activate
msg_ok "pnpm $(pnpm --version) enabled"

msg_info "Installing Docker (with Compose, Buildx)"
DOCKER_CONFIG_PATH='/etc/docker/daemon.json'
mkdir -p $(dirname $DOCKER_CONFIG_PATH)
echo -e '{\n  "log-driver": "journald"\n}' >/etc/docker/daemon.json
$STD sh <(curl -fsSL https://get.docker.com)
msg_ok "Installed Docker $(docker --version | awk '{print $3}' | sed 's/,//')"

msg_info "Starting Docker service"
systemctl enable docker.service
systemctl start docker.service
msg_ok "Docker service started"

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

if ./docker-setup.sh; then
  msg_ok "Installed OpenClaw"
else
  msg_error "OpenClaw setup failed. Check logs above for details."
  exit 1
fi

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