#!/bin/bash

# Instal az link from official microsoft page
# https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt
curl -fsL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Install kubectl
curl -fLO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# zip to unzip terraform
apt-get -y install zip

# Terraform
wget https://releases.hashicorp.com/terraform/0.13.4/terraform_0.13.4_linux_amd64.zip
unzip terraform_0.13.4_linux_amd64.zip
chmod u+x ./terraform
mv ./terraform /usr/local/bin
