#!/bin/bash

# file: install-docker.sh
# author: @wgxo

# Script that installs docker and docker-compose in Ubuntu

set -x

sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

if [ -z $(grep -Poe eoan /etc/apt/sources.list) ]; then
    DIST=$(lsb_release -cs)
else
    DIST="disco"
fi
sudo add-apt-repository  "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $DIST stable"

sudo apt-get update
sudo apt-get -y install docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
sudo curl -L https://github.com/docker/compose/releases/download/1.17.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

echo ""
echo "**************************************************************"
echo " The current user was added to the docker group."
echo " You might need to log out and back in to refresh permissions"
echo "**************************************************************"
echo ""
