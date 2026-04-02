locals {
  private_ssh_key_path = var.ssh_private_key_path == null ? "${path.cwd}/${var.prefix}-ssh_private_key.pem" : var.ssh_private_key_path
  public_ssh_key_path  = var.ssh_public_key_path == null ? "${path.cwd}/${var.prefix}-ssh_public_key.pem" : var.ssh_public_key_path
  instance_count       = 1
  instance_os_type     = "opensuse"
  os_image_family      = "opensuse-leap"
  os_image_project     = "opensuse-cloud"
  ssh_username         = local.instance_os_type
  certified_image_name = "opensuse-leap-15-6-suse-ai-tf-cloud-image.x86_64.raw.tar.gz"
  certified_image_url  = var.certified_os_image ? "https://github.com/devenkulkarni/suse-ai-tf/releases/download/${var.certified_os_image_tag}/${local.certified_image_name}" : null
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

resource "local_file" "public_key_pem" {
  count           = var.create_ssh_key_pair ? 1 : 0
  filename        = local.public_ssh_key_path
  content         = tls_private_key.ssh_private_key[0].public_key_openssh
  file_permission = "0600"
}

data "google_compute_image" "os_image" {
  family  = local.os_image_family
  project = local.os_image_project

}

resource "null_resource" "download_image" {
  count = var.certified_os_image ? 1 : 0
  provisioner "local-exec" {
    command = <<EOT
      curl -fL -o ${path.cwd}/${var.prefix}-image.tar.gz ${local.certified_image_url}
    EOT
  }
}

resource "google_storage_bucket" "images_bucket" {
  count         = var.certified_os_image ? 1 : 0
  name          = "${var.prefix}-certified-img-bucket"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "certified_image" {
  depends_on = [null_resource.download_image]
  count      = var.certified_os_image ? 1 : 0
  name       = "${var.prefix}-image-raw.tar.gz"
  bucket     = google_storage_bucket.images_bucket[0].name
  source     = "${path.cwd}/${var.prefix}-image.tar.gz"
}

resource "google_compute_image" "upload_certified_image" {
  depends_on = [google_storage_bucket_object.certified_image]
  count      = var.certified_os_image ? 1 : 0
  name       = "${var.prefix}-opensuse-certified-img"
  raw_disk {
    source = "https://storage.googleapis.com/${google_storage_bucket.images_bucket[0].name}/${google_storage_bucket_object.certified_image[0].name}"
  }
}

resource "google_compute_network" "vpc" {
  count                   = var.create_vpc == true ? 1 : 0
  name                    = "${var.prefix}-vpc"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "subnet" {
  count         = var.create_vpc == true ? 1 : 0
  name          = "${var.prefix}-subnet"
  region        = var.region
  network       = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
  ip_cidr_range = var.ip_cidr_range
}

resource "google_compute_firewall" "default" {
  count   = var.create_firewall ? 1 : 0
  name    = "${var.prefix}-firewall"
  network = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["6443", "22", "80", "443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["${var.prefix}"]
}

data "google_compute_zones" "available" {
  region = var.region
  status = "UP"
}

resource "random_string" "random" {
  length  = 4
  lower   = true
  numeric = false
  special = false
  upper   = false
}

resource "google_compute_disk" "data_disk" {
  count = var.data_disk_count
  name  = "${var.prefix}-data-disk-${count.index + 1}-${random_string.random.result}"
  type  = var.data_disk_type
  size  = var.data_disk_size
  zone  = var.zone
}

resource "google_compute_instance" "default" {
  count        = local.instance_count
  name         = "${var.prefix}-vm-${count.index + 1}-${random_string.random.result}"
  machine_type = var.instance_type
  zone         = var.zone
  tags         = ["${var.prefix}"]
  scheduling {
    preemptible         = var.spot_instance
    provisioning_model  = var.spot_instance ? "SPOT" : "STANDARD"
    automatic_restart   = var.spot_instance ? false : true
    on_host_maintenance = "TERMINATE"
  }
  boot_disk {
    initialize_params {
      type = var.os_disk_type
      size = var.os_disk_size
      # image = data.google_compute_image.os_image.self_link
      image = var.certified_os_image ? google_compute_image.upload_certified_image[0].self_link : data.google_compute_image.os_image.self_link
    }
  }
  # Add GPU here:
  guest_accelerator {
    type  = var.gpu_type  # e.g., "nvidia-tesla-t4"
    count = var.gpu_count # e.g., 1
  }

  dynamic "scratch_disk" {
    for_each = []
    content {
      interface = "SCSI"
    }
  }
  dynamic "attached_disk" {
    for_each = google_compute_disk.data_disk
    content {
      source = attached_disk.value.self_link
    }
  }
  network_interface {
    network    = var.vpc == null ? resource.google_compute_network.vpc[0].name : var.vpc
    subnetwork = var.subnet == null ? resource.google_compute_subnetwork.subnet[0].name : var.subnet
    access_config {}
  }
  metadata = {
    serial-port-logging-enable = "TRUE"
    serial-port-enable         = "TRUE"
    ssh-keys                   = var.create_ssh_key_pair ? "${local.ssh_username}:${tls_private_key.ssh_private_key[0].public_key_openssh}" : "${local.ssh_username}:${file(local.public_ssh_key_path)}"
    startup-script             = templatefile("${path.module}/scripts/startupscript.tftpl", {})
  }
  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      boot_disk[0].initialize_params[0].image
    ]
  }
}

resource "null_resource" "wait_for_gpu" {
  # This ensures the GPU driver and compute utils are installed correctly only starts after the VM is actually created
  depends_on = [google_compute_instance.default]

  provisioner "remote-exec" {
    connection {
      type = "ssh"
      user = local.ssh_username
      # Use the private key generated by your tls_private_key resource
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
      host        = google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip
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
      templatefile("${path.module}/scripts/rke2-localpath-install.sh", {
        public_ip    = google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip
        rke2_version = var.rke2_version
      })
    ]

    connection {
      type        = "ssh"
      user        = local.ssh_username
      private_key = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
      host        = google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip
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
      host        = google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip
    }
  }

  provisioner "local-exec" {
    command = <<EOT
      scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
          -i ${local.private_ssh_key_path} \
          ${local.ssh_username}@${google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip}:/tmp/rke2.yaml \
          ./kubeconfig-rke2.yaml
      
      # Detect OS and run the correct sed command
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/127.0.0.1/${google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip}/g" ./kubeconfig-rke2.yaml
      else
        sed -i "s/127.0.0.1/${google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip}/g" ./kubeconfig-rke2.yaml
      fi
      
      echo "Kubeconfig successfully retrieved and updated."
    EOT
  }

  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ./kubeconfig-rke2.yaml"
  }
}
