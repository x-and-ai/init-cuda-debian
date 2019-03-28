#!/bin/bash

# terminal color code
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# get current user
CURRENT_USER=$USER

# install sudo and granting current user sudo permission (our minimal debian installation doesn't have sudo by default)
SU_COMMAND="apt update && apt upgrade -y && apt install sudo -y && usermod -aG sudo $CURRENT_USER"

# more than just setting up sudo, we also disable nouveau for using CUDA
DISABLE_NOUVEAU_FILE="/etc/modprobe.d/disable-nouveau.conf"
SU_COMMAND+=" && echo 'blacklist nouveau' > $DISABLE_NOUVEAU_FILE && echo 'options nouveau modeset=0' >> $DISABLE_NOUVEAU_FILE"

# run as root
printf "${GREEN}Granting ${CURRENT_USER} sudo permission and disable nouveau ...${NO_COLOR}\n"
printf "${GREEN}Please Enter ROOT User's Password${NO_COLOR}\n"
if ! su -c "$SU_COMMAND"; then
  printf "${RED}Running into error while installing sudo and adding ${CURRENT_USER} to sudo group :(${NO_COLOR}\n"
  exit 0
fi
