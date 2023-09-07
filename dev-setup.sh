#!/bin/bash

## Script to setup Dev Enviornment


## Clean Up Environment
for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt-get remove $pkg; done

## Set GPG Keys
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo add-apt-repository --yes --update ppa:ansible/ansible

## Install Required packages
sudo apt update
sudo apt install -y software-properties-common
sudo apt install -y terraform ansible packer docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin awscli
sudo docker run hello-world

## Verify installation
echo "Terraform Version"
terraform -version
echo ""

echo "Packer Version"
packer -version
echo ""

echo "Docker Version"
docker --version
echo ""

echo "Ansible Version"
ansible --version | grep core
echo ""
echo "AWS Cli Version"
aws --version
