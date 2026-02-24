#!/bin/bash
set -e

# Define absolute paths to avoid PATH issues in remote-exec
K8S_BIN="/var/lib/rancher/rke2/bin/kubectl"
K8S_CONFIG="/etc/rancher/rke2/rke2.yaml"

echo "Starting RKE2 installation..."

# 1. Create RKE2 directories
sudo mkdir -p /etc/rancher/rke2/
sudo mkdir -p /var/lib/rancher/rke2/server/manifests/

# 2. Generate Config
sudo tee /etc/rancher/rke2/config.yaml > /dev/null <<EOF
tls-san:
  - ${public_ip}
disable:
  - rke2-ingress-nginx
ingress-controller: traefik
EOF

# 3. Install RKE2
curl -sfL https://get.rke2.io | sudo INSTALL_RKE2_VERSION=${rke2_version} sh -

# 4. Enable and Start Service
sudo systemctl enable --now rke2-server

# 5. Wait for Service to be Active
echo "Waiting for rke2-server service to start..."
until sudo systemctl is-active --quiet rke2-server; do
    sleep 5
done

# 6. Apply Local Path Provisioner
echo "Applying Local Path Provisioner..."
# We use the absolute path to kubectl and point to the config explicitly
sudo $K8S_BIN --kubeconfig $K8S_CONFIG apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml

echo "RKE2 installation with localpath storage provisioner completed successfully."
