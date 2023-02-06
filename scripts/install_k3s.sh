#!/bin/bash

TENANT_ID=$1
SUBSCRIPTION_ID=$2
RESOURCE_GROUP=$3
ADMIN_USERNAME=$4
PUBLIC_IP=$5

# Installing Rancher K3s single master cluster using k3sup
sudo apt-get update
sudo -u $ADMIN_USERNAME mkdir /home/${ADMIN_USERNAME}/.kube
curl -sLS https://get.k3sup.dev | sh
sudo cp k3sup /usr/local/bin/k3sup
sudo k3sup install --local --context arck3sdemo --ip $PUBLIC_IP
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
sudo cp kubeconfig /home/${ADMIN_USERNAME}/.kube/config
chown -R $ADMIN_USERNAME /home/${ADMIN_USERNAME}/.kube/

# Ensure default namespace is labelled
kubectl label ns kube-system name=kube-system

# Set up Managed Identity
sudo rm -rf "/etc/kubernetes/azure.json"
sudo mkdir -p "/etc/kubernetes/"

echo "{
  \"cloud\": \"AzurePublicCloud\",
  \"tenantId\": \"$TENANT_ID\",
  \"subscriptionId\": \"$SUBSCRIPTION_ID\",
  \"resourceGroup\": \"$RESOURCE_GROUP\",
  \"useManagedIdentityExtension\": true
}" | sudo tee /etc/kubernetes/azure.json
