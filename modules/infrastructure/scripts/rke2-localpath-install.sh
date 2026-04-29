#!/bin/bash
set -e

# Define absolute paths to avoid PATH issues in remote-exec
K8S_BIN="/var/lib/rancher/rke2/bin/kubectl"
K8S_CONFIG="/etc/rancher/rke2/rke2.yaml"

# Define Trusted Checksums:
RKE2_INSTALL_SHA="49b21b3edd6f2ba87e732aeb6a709668302806efb55a060f64db9f680c97dfe096ecc9ec4f95ecaa30af46042c288c115c1d54b9566e4313b993e147b8c442d4"
LOCAL_PATH_SHA="b7ad6b277a3fa2950fe86ecaf475db7bc5276b284a9fe662f56b10d182304f9e939ca92a823943560275586474c09d42cb6dfaeb51de3273ca7004c90127eaf8"

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
echo "Downloading and verifying RKE2 installer..."
curl -sfL -o install_rke2.sh https://get.rke2.io
echo "$RKE2_INSTALL_SHA  install_rke2.sh" | sha512sum -c -
sudo INSTALL_RKE2_VERSION=${rke2_version} sh install_rke2.sh

# 4. Enable and Start Service
sudo systemctl enable --now rke2-server

# 5. Wait for Service to be Active
TIMEOUT=600 # 10 minutes
END_TIME=$(( $${SECONDS} + $${TIMEOUT} ))

echo "Waiting for rke2-server to start (Timeout: $${TIMEOUT}s)..."

while true; do
    # 1. Check if the service is active (Success)
    if sudo systemctl is-active --quiet rke2-server; then
        echo "Success: rke2-server is active."
        break
    fi

    # 2. Check if the service explicitly failed (Early Exit)
    if sudo systemctl is-failed --quiet rke2-server; then
        echo "Error: rke2-server service entered a FAILED state."
        echo "--- Last 20 lines of logs ---"
        sudo journalctl -u rke2-server --no-pager -n 20
        exit 1
    fi

    # 3. Check for Timeout
    if [ "$${SECONDS}" -ge "$${END_TIME}" ]; then
        echo "Error: Timed out waiting for rke2-server after $${TIMEOUT} seconds."
        echo "--- Last 20 lines of logs ---"
        sudo journalctl -u rke2-server --no-pager -n 20
        exit 1
    fi

    sleep 5
done

# 6. Apply Local Path Provisioner
echo "Applying Local Path Provisioner..."
echo "Downloading and verifying Local Path Provisioner manifest..."
LOCAL_PATH_URL="https://raw.githubusercontent.com/rancher/local-path-provisioner/v0.0.31/deploy/local-path-storage.yaml"
curl -sfL -o local-path-storage.yaml "$LOCAL_PATH_URL"
echo "$LOCAL_PATH_SHA  local-path-storage.yaml" | sha512sum -c -

# We use the absolute path to kubectl and point to the config explicitly
sudo $K8S_BIN --kubeconfig $K8S_CONFIG apply -f local-path-storage.yaml

echo "RKE2 installation with localpath storage provisioner completed successfully."
