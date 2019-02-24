#!/usr/bin/env bash

# Update Package Sources
sudo apt-get update

# Install EasyEngine
wget -qO ee rt.cx/ee4 && sudo bash ee

# Install Tools
sudo apt-get install -y vim htop dnsutils mysql-client less git

# Install dns stuff
#sudo apt-get install -y dnsmasq