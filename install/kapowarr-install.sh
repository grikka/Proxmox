#!/bin/bash
# Kapowarr Installation Script
# Author: Greg Mills
# Description: This script automates the installation of Kapowarr on a Proxmox system.

source /dev/stdin <<< "$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

# Update and install dependencies
msg_info "Updating package list and installing dependencies..."
$STD apt-get update
$STD apt-get install -y curl sudo
msg_ok "Installed Dependencies"

# Install Docker
msg_info "Installing Docker..."
$STD curl -fsSL https://get.docker.com -o get-docker.sh
$STD sh get-docker.sh
msg_ok "Installed Docker"

# Create a Docker group and add the current user
msg_info "Configuring Docker group..."
$STD groupadd docker
$STD usermod -aG docker $USER
$STD newgrp docker
msg_ok "Docker Configured"


# Installing Kapowarr
msg_info "Creating directory for Kapowarr..."
mkdir -p /opt/kapowarr
cd /opt/kapowarr
curl -o docker-compose.yml https://raw.githubusercontent.com/Casvt/Kapowarr/master/docker-compose.yml
docker-compose up -d
msg_ok "Kapowarr Configured"

motd_ssh
customize

msg_info "Cleaning up"
rm -rf Kapowarr.master.*.tar.gz
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"