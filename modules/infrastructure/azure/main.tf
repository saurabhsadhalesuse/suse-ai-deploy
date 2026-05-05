locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  certified_image_name = "opensuse-leap-15-6-suse-ai-tf-cloud-image.x86_64.vhd"
  certified_image_url  = "https://github.com/devenkulkarni/suse-ai-tf/releases/download/${var.certified_os_image_tag}/${local.certified_image_name}"
  certified_image_sha512 = "5cdf863e0548498585e951e861adee67054fb7f762161cdbf6e469b9a63564aa256a53cb9f8009cac9aaf6c7467de938a9c2a3d3ea2c756aa99f295b487defc5"
  ssh_username         = "opensuse" 
}

resource "tls_private_key" "ssh_private_key" {
  count     = var.create_ssh_key_pair ? 1 : 0
  algorithm = "ED25519"
}

resource "local_file" "private_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.private_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].private_key_openssh
  file_permission = "0600"
}

# --- Networking ---
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location
}

resource "azurerm_storage_account" "vhd" {
  name                            = var.prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_storage_container" "vhds" {
  name                  = "vhds"
  storage_account_id    = azurerm_storage_account.vhd.id
  container_access_type = "private"
}

resource "null_resource" "download_certified_vhd" {
  provisioner "local-exec" {
    command = <<-EOT
      set -eu

      FILE="${path.cwd}/${local.certified_image_name}"
      EXPECTED="${local.certified_image_sha512}"

      if [ -f "$FILE" ]; then
        echo "File exists. Verifying checksum..."

        if echo "$EXPECTED  $FILE" | sha512sum -c - >/dev/null 2>&1; then
          echo "Checksum valid. Skipping download."
          exit 0
        else
          echo "Checksum mismatch. Re-downloading..."
          rm -f "$FILE"
        fi
      fi

      echo "Downloading + hashing in one pass..."

      ACTUAL=$(curl -L --fail --retry 5 --retry-delay 5 "${local.certified_image_url}" \
        | tee "$FILE" \
        | sha512sum | awk '{print $1}')

      if [ "$ACTUAL" != "$EXPECTED" ]; then
        echo "ERROR: Checksum mismatch!"
        rm -f "$FILE"
        exit 1
      fi

      echo "Download + checksum verification successful."
    EOT
  }
}

resource "azurerm_storage_blob" "suseaitf_vhd" {
  depends_on             = [null_resource.download_certified_vhd]
  name                   = "suseaitfcloudcertified.vhd"
  storage_account_name   = azurerm_storage_account.vhd.name
  storage_container_name = azurerm_storage_container.vhds.name
  type                   = "Page"
  source                 = "${path.cwd}/${local.certified_image_name}"
}

resource "null_resource" "wait_blob_accessible" {
  depends_on = [azurerm_storage_blob.suseaitf_vhd]
  provisioner "local-exec" {
    command = <<EOT
      BLOB_URI=${azurerm_storage_blob.suseaitf_vhd.url}
      ACCOUNT_KEY=$(az storage account keys list -g ${azurerm_resource_group.rg.name} -n ${azurerm_storage_account.vhd.name} --query '[0].value' -o tsv)

      for i in {1..20}; do
        az disk create --name temp-check-disk --resource-group ${azurerm_resource_group.rg.name} --source "$BLOB_URI" --location ${azurerm_resource_group.rg.location} --sku Standard_LRS > /dev/null 2>&1 && break || echo "Blob not ready, retry in 15s" && sleep 15
      done
      echo "blob ready, creating Image from Blob"
      az disk delete --name temp-check-disk -g ${azurerm_resource_group.rg.name} --yes > /dev/null 2>&1
    EOT
  }
}

resource "azurerm_image" "suseaitf" {
  depends_on          = [null_resource.wait_blob_accessible]
  name                = "SUSEAITFCloudCertifiedImage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_disk {
    os_type      = "Linux"
    os_state     = "Generalized"
    blob_uri     = azurerm_storage_blob.suseaitf_vhd.url
    storage_type = "Standard_LRS"
  }
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "pip" {
  count               = local.instance_count
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# --- Security Groups (NSG) ---
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefixes      = var.public_ip_source_addresses
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "RKE2-API"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6443"
    source_address_prefixes      = var.public_ip_source_addresses
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTP-S"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["80", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "nic" {
  count               = local.instance_count
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[count.index].id
  }
}

resource "azurerm_network_interface_security_group_association" "nic_nsg" {
  count                     = local.instance_count
  network_interface_id      = azurerm_network_interface.nic[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg.id

  depends_on = [
    azurerm_network_interface.nic
  ]
}

# --- Virtual Machine ---
resource "azurerm_linux_virtual_machine" "opensuse_gpu" {
  count               = local.instance_count
  name                = "${var.prefix}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.instance_type # e.g., Standard_NC6s_v3
  admin_username      = local.ssh_username

  network_interface_ids = [azurerm_network_interface.nic[count.index].id]

  admin_ssh_key {
    username   = local.ssh_username
    public_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].public_key_openssh : file(local.public_ssh_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size
  }

  source_image_id = azurerm_image.suseaitf.id

  custom_data = base64encode(templatefile("${path.module}/../scripts/startupscript.tftpl", { cloud_provider = "azure" }))

  tags = {
    Name = "${var.prefix}-opensuse-rke2"
  }
}

# --- Provisioning Logic ---

resource "null_resource" "wait_for_gpu" {
  depends_on = [azurerm_linux_virtual_machine.opensuse_gpu]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = local.ssh_username
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
      host        = azurerm_public_ip.pip[0].ip_address
      timeout     = "15m"
    }

    inline = [
      "echo 'Waiting for GPU Driver installation to complete...'",
      # This loop waits for nvidia-smi to be available in the PATH
      # timeout 600 ensures it doesn't loop forever (10 minutes max)
      "timeout 600 bash -c 'until command -v nvidia-smi &> /dev/null; do echo \"Still waiting for nvidia-smi...\"; sleep 20; done'",
      "echo 'GPU Driver detected!'",
      "nvidia-smi",
      "echo 'Setup script verified. Environment is ready.'"
    ]
  }
}

resource "null_resource" "rke2_installation" {
  depends_on = [null_resource.wait_for_gpu]

  provisioner "remote-exec" {
    inline = [
      templatefile("${path.module}/../scripts/rke2-localpath-install.sh", {
        public_ip      = azurerm_public_ip.pip[0].ip_address
        rke2_version   = var.rke2_version
        cloud_provider = "azure"
      })
    ]

    connection {
      type        = "ssh"
      user        = local.ssh_username
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
      host        = azurerm_public_ip.pip[0].ip_address
    }
  }
}

resource "null_resource" "retrieve_kubeconfig" {
  depends_on = [null_resource.rke2_installation]

  provisioner "remote-exec" {
    inline = [
      "sudo cp /etc/rancher/rke2/rke2.yaml /tmp/rke2.yaml",
      "sudo chown ${local.ssh_username} /tmp/rke2.yaml",
      "sudo chmod 644 /tmp/rke2.yaml"
    ]

    connection {
      type        = "ssh"
      user        = local.ssh_username
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
      host        = azurerm_public_ip.pip[0].ip_address
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
          -i ${local.private_ssh_key_path} \
          ${local.ssh_username}@${azurerm_public_ip.pip[0].ip_address}:/tmp/rke2.yaml \
          ./kubeconfig-rke2.yaml
      
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/127.0.0.1/${azurerm_public_ip.pip[0].ip_address}/g" ./kubeconfig-rke2.yaml
      else
        sed -i "s/127.0.0.1/${azurerm_public_ip.pip[0].ip_address}/g" ./kubeconfig-rke2.yaml
      fi
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ./kubeconfig-rke2.yaml"
  }
}


#resource "null_resource" "cleanup_certified_vhd" {
#  depends_on = [null_resource.retrieve_kubeconfig]
#  count      = var.certified_os_image ? 1 : 0
#  provisioner "local-exec" {
#    when    = destroy
#    command = "rm ${path.cwd}/opensuse-leap-15-6-suse-ai-tf-cloud-image.x86_64.vhd"
#  }
#}
