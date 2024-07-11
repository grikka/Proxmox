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
msg_info "Updating package list and installing dependencies"
$STD apt-get update
$STD apt-get install -y curl sudo
msg_ok "Installed Dependencies"

# Install Docker
msg_info "Installing Docker"
$STD curl -fsSL https://get.docker.com -o get-docker.sh
$STD sh get-docker.sh
msg_ok "Installed Docker"

# Create a Docker group and add the current user
msg_info "Configuring Docker group"
$STD groupadd docker
$STD usermod -aG docker root
$STD newgrp docker
msg_ok "Docker Configured"


# Installing Kapowarr
msg_info "Installing Kapowarr"
docker volume create kapowarr-db
mkdir -p /opt/kapowarr
cd /opt/kapowarr
cat <<EOF >/opt/kapowarr/docker-compose.yml
version: "3.3"
services:
  kapowarr:
    container_name: kapowarr
    image: mrcas/kapowarr:latest
    volumes:
      - "kapowarr-db:/app/db"
      - "{your_local_path}:/app/temp_downloads"
      - "{your_local_comics_path}:/Comics"
    ports:
      - 5656:5656

volumes:
  kapowarr-db:
EOF
docker-compose up -d
msg_ok "Kapowarr Configured"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"