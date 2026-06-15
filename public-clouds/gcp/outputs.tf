output "suse_ai_webui_url" {
  description = "URL for accessing the SUSE AI Web UI"
  value       = "suse-ai.${module.infrastructure.instance_public_ip}.sslip.io"
}

output "instance_public_ip" {
  description = "The public IP of the openSUSE VM"
  value       = module.infrastructure.instance_public_ip
}

output "kubeconfig_path" {
  description = "Local path to the generated kubeconfig file"
  value       = "${path.cwd}/kubeconfig-rke2.yaml"
}

output "ssh_command" {
  description = "Convenience command to SSH into the VM"
  value       = "ssh -i ${local.private_ssh_key_path} ${local.ssh_username}@${module.infrastructure.instance_public_ip}"
}
