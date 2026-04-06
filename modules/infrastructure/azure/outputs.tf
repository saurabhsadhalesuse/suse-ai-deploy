output "instance_public_ip" {
  description = "The public IP address of the Azure VM"
  # In Azure, we reference the Public IP resource directly
  value = azurerm_public_ip.pip[0].ip_address
}

output "kubeconfig_path" {
  description = "Path to the generated Kubeconfig file"
  value       = "${path.cwd}/kubeconfig-rke2.yaml"
}

output "ssh_command" {
  description = "Convenience command to login via SSH"
  value       = "ssh -i ${local.private_ssh_key_path} ${local.ssh_username}@${azurerm_public_ip.pip[0].ip_address}"
}

output "kubeconfig_done" {
  description = "ID of the Kubeconfig retrieval resource to track completion"
  value       = null_resource.retrieve_kubeconfig.id
}

output "ssh_private_key_content" {
  description = "The content of the generated private key"
  value       = var.create_ssh_key_pair ? tls_private_key.ssh_private_key[0].private_key_openssh : file(local.private_ssh_key_path)
  sensitive   = true
}
