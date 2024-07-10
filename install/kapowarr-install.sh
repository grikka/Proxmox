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
echo "Updating package list and installing dependencies..."
apt-get update
apt-get install -y curl sudo

# Install Docker
echo "Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Create a Docker group and add the current user
echo "Configuring Docker group..."
groupadd docker
usermod -aG docker $USER
newgrp docker

# Create a directory for Kapowarr
echo "Creating directory for Kapowarr..."
mkdir -p /opt/kapowarr
cd /opt/kapowarr

# Download and configure Kapowarr Docker Compose file
echo "Downloading Docker Compose file for Kapowarr..."
curl -o docker-compose.yml https://raw.githubusercontent.com/Casvt/Kapowarr/master/docker-compose.yml

# Start Kapowarr using Docker Compose
echo "Starting Kapowarr..."
docker-compose up -d

# Completion message
echo "Kapowarr installation is complete. You can access Kapowarr on port 8585."
