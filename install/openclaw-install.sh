#!/usr/bin/env bash
source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"

color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Configuring Locale"
if command -v locale-gen >/dev/null 2>&1; then
    sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen 2>/dev/null || true
    locale-gen >/dev/null 2>&1 || true
fi
echo "LANG=C.UTF-8" >/etc/default/locale
export LANG=C.UTF-8
export LC_ALL=C.UTF-8
msg_ok "Locale Configured"

msg_info "Installing Dependencies"
$STD apt-get install -y curl git mc sudo
msg_ok "Installed Dependencies"

msg_info "Installing Docker"
if ! command -v docker &> /dev/null; then
    $STD curl -fsSL https://get.docker.com | sh
    systemctl enable --now docker
    # Add user to docker group if needed, though this script runs as root
fi
msg_ok "Installed Docker"

msg_info "Installing OpenClaw"
# Create application directory
mkdir -p /opt/openclaw
cd /opt/openclaw

# Clone Repository (Using the 2026 recognized repo)
$STD git clone https://github.com/openclaw/openclaw.git .

# Create .env file or config if necessary (Basic default setup)
# This assumes the repo has a default docker-compose.yml that works out of the box
if [ -f "env.example" ]; then
    cp env.example .env
fi

# Pull and Start Docker Containers
$STD docker compose up -d

msg_ok "Installed OpenClaw"

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"