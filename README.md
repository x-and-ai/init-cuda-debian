# Debian Nvidia Server Initial Setup Script

This is our script to initialize a debian server (brand new clean netinst) with Nvidia GPUs with supports of Docker and Nvidia-Docker.

> Current scripts have **ONLY** been tested using a local MacOS Mojave terminal (with zshell) to setup a remote clean netinst Debian 9 server.
> Adjustments are most likely required to apply on other systems.

## Features

1. Setup SSH key login and disable password login.

1. Grant admin user sudo permission.

1. Setup UFW.

1. Setup Nvidia CUDA driver.

1. Setup Docker and Nvidia Docker.

1. Setup git and net-tools.

## Prerequisite

1. A remote server with Nvidia GPU.

1. SSH with password login has been enabled on remote server.

1. Local id_rsa SSH key pairs.

## Usage

1. Download CUDA driver from <https://developer.nvidia.com/cuda-downloads>, and put it inside the root of this directory.

1. Update `config.sh` and per your environments

1. Make changes to the scripts per your needs

1. Run `./main.sh`
