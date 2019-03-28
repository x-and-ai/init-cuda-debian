#!/bin/bash

# configurations
DOCKER_APT_KEY_FINGERPRINT="9DC8 5822 9FC7 DD38 854A E2D8 8D81 803C 0EBF CD88"

# terminal color code
RED='\033[0;31m'
GREEN='\033[0;32m'
NO_COLOR='\033[0m'

# arguments
CUDA_DRIVER_RUNFILE=$1

# take cuda driver file path input
input_cuda_file_path() {
  printf "${GREEN}Please Enter CUDA Driver Run File Path:${NO_COLOR} "
  read CUDA_DRIVER_RUNFILE
  check_cuda_file_path
}

# check cuda driver file exists
check_cuda_file_path() {
  if [ ! -x $CUDA_DRIVER_RUNFILE ]; then
    printf "${RED}Didn't find any executable file at $CUDA_DRIVER_RUNFILE :(${NO_COLOR}\n"
    input_cuda_file_path
  fi
}

# check if cuda driver file path is provided
if [ -z $CUDA_DRIVER_RUNFILE ]; then
  input_cuda_file_path
else
  check_cuda_file_path
fi

# install uncomplicated firewall
printf "${GREEN}Setting up UFW ...${NO_COLOR}\n"

sudo apt install ufw -y

if ! sudo ufw app list | grep -q OpenSSH; then
  printf "${RED}Didn't find OpenSSH in UFW app list :(${NO_COLOR}\n"
  exit 0
fi

sudo ufw allow OpenSSH
sudo ufw enable

if ! sudo ufw status | grep -q OpenSSH; then
  printf "${RED}Failed to setup UFW :(${NO_COLOR}\n"
  exit 0
fi

# leave an empty new line
echo ''

# disable SSH password login
printf "${GREEN}Disabling SSH password login ...${NO_COLOR}\n"
sudo sed -i "s/#PasswordAuthentication.*/PasswordAuthentication no/g" /etc/ssh/sshd_config

if grep -q "^PasswordAuthentication no$" /etc/ssh/sshd_config; then
  printf "${GREEN}Disabled SSH password login :)${NO_COLOR}\n"
else
  printf "${RED}Failed to disable SSH password login :(${NO_COLOR}\n"
  exit 0
fi

# leave an empty new line
echo ''

# install some common packages
printf "${GREEN}Installing some common packages ...${NO_COLOR}\n"
sudo apt install -y git lshw hwinfo net-tools

# leave an empty new line
echo ''

# install Nvidia driver
printf "${GREEN}Setting up CUDA driver dependencies ...${NO_COLOR}\n"
sudo apt install -y linux-headers-`uname -r` build-essential freeglut3-dev libx11-dev libxmu-dev libxi-dev libgl1-mesa-glx libglu1-mesa libglu1-mesa-dev
sudo update-initramfs -u
echo ''
printf "${GREEN}Setting up CUDA driver ...${NO_COLOR}\n"
sudo sh $CUDA_DRIVER_RUNFILE

# leave an empty new line
echo ''

# install Docker and Docker Compose
printf "${GREEN}Setting up Docker dependencies ...${NO_COLOR}\n"
sudo apt update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
echo ''
printf "${GREEN}Installing Docker and Docker Compose ...${NO_COLOR}\n"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -

apt_key_fingerprint=$(sudo apt-key fingerprint 0EBFCD88 2>/dev/null | tr -d ' ')
echo $apt_key_fingerprint
docker_apt_key_fingerprint=$(tr -d ' ' <<< "$DOCKER_APT_KEY_FINGERPRINT")

if [[ ! "$apt_key_fingerprint" =~ .*"$docker_apt_key_fingerprint".* ]]; then
  printf "${RED}Failed to validate Docker GPG key fingerprint :(${NO_COLOR}\n"
  exit 0
fi

sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
sudo apt update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo usermod -aG docker $USER

# leave an empty new line
echo ''

# install nvidia-docker2
printf "${GREEN}Installing nvidia-docker ...${NO_COLOR}\n"
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | \
  sudo apt-key add -
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
  sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-docker2
sudo pkill -SIGHUP dockerd

# leave an empty new line
echo ''

printf "${GREEN}Setup completed. Rebooting ...${NO_COLOR}\n"
sudo reboot
