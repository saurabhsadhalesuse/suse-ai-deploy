output "instance_public_ip" {
  description = "The public IP of the GPU instance"
  value       = google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip
}

output "ssh_command" {
  description = "Convenience command to login"
  value       = "ssh -i ${local.private_ssh_key_path} ${local.ssh_username}@${google_compute_instance.default[0].network_interface[0].access_config[0].nat_ip}"
}

output "kubeconfig_path" {
  value = "${path.cwd}/kubeconfig-rke2.yaml"
}

output "ssh_private_key_content" {
  description = "The content of the generated private key"
  value       = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
  sensitive   = true
}

output "kubeconfig_done" {
  value = null_resource.retrieve_kubeconfig.id
}

