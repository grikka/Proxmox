#!/bin/bash
# Mylar3 Installation Script
# Author: Greg Mills
# Description: This script automates the installation of Mylar3 on a Proxmox system.

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


# Installing Mylar3
msg_info "Installing Mylar3"
mkdir -p /opt/mylar3
cd /opt/mylar3
cat <<EOF >/opt/mylar3/docker-compose.yml
version: "2.1"
services:
  mylar3:
    image: lscr.io/linuxserver/mylar3:latest
    container_name: mylar3
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/data:/config
      - /path/to/comics:/comics
      - /path/to/downloads:/downloads
    ports:
      - 8090:8090
    restart: unless-stopped
EOF
docker-compose up -d
msg_ok "Mylar3 Configured"

motd_ssh
customize

msg_info "Cleaning up"
$STD apt-get -y autoremove
$STD apt-get -y autoclean
msg_ok "Cleaned"