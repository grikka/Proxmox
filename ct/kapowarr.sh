#!/usr/bin/env bash

source <(curl -s https://raw.githubusercontent.com/tteck/Proxmox/main/misc/build.func)

# Copyright (c) 2021-2024 tteck

# Author: tteck (tteckster)

# License: MIT

# https://github.com/tteck/Proxmox/raw/main/LICENSE

function header_info {
clear
cat <<"EOF"
  _  __                        __
 | |/ /____  ____ _____  _____/ /_
 |   / ___ \/ __ `/ __ \/ ___/ __/
/   / /_/ / /_/ / / / / /__/ /_  
/_/|_/ .___/\__,_/_/ /_/\___/\__/  
    /_/                            
EOF
}

header_info
echo -e "Loading..."

APP="Kapowarr"
var_disk="4"
var_cpu="2"
var_ram="1024"
var_os="debian"
var_version="12"

variables
color
catch_errors

function default_settings() {
  CT_TYPE="1"
  PW=""
  CT_ID=$NEXTID
  HN=$NSAPP
  DISK_SIZE="$var_disk"
  CORE_COUNT="$var_cpu"
  RAM_SIZE="$var_ram"
  BRG="vmbr0"
  NET="dhcp"
  GATE=""
  APT_CACHER=""
  APT_CACHER_IP=""
  DISABLEIP6="no"
  MTU=""
  SD=""
  NS=""
  MAC=""
  VLAN=""
  SSH="no"
  VERB="no"
  echo_default
}

function update_script() {
  header_info
  if [[ ! -f /etc/apt/sources.list.d/kapowarr.list ]]; then msg_error "No ${APP} Installation Found!"; exit; fi
  msg_info "Updating ${APP} LXC"
  apt-get update &>/dev/null
  apt-get -y upgrade &>/dev/null
  msg_ok "Updated Successfully"
  exit
}

start
build_container
description

msg_info "Setting up ${APP} Repository"
wget -qO- https://apt.sonarr.tv/pub.key | apt-key add - >/dev/null
echo "deb https://apt.sonarr.tv/debian buster main" | tee /etc/apt/sources.list.d/kapowarr.list >/dev/null
msg_ok "Added ${APP} Repository"

msg_info "Installing ${APP}"
apt-get update &>/dev/null
apt-get install -y kapowarr &>/dev/null
systemctl enable --now kapowarr.service &>/dev/null
msg_ok "Installed ${APP}"

description

msg_info "${APP} should be reachable by going to the following URL."
echo -e "${BL}http://${IP}:5656${CL} \n"
