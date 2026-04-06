output "instance_public_ip" {
  description = "The public IP of the GPU instance"
  value       = module.infrastructure.instance_public_ip
}

output "ssh_command" {
  description = "Convenience command to login"
  value       = "ssh -i ${local.private_ssh_key_path} ${local.ssh_username}@${module.infrastructure.instance_public_ip}"
}

output "kubeconfig_path" {
  value = "${path.cwd}/kubeconfig-rke2.yaml"
}

output "suse_ai_webui_url" {
  description = "URL for accessing the SUSE AI webUI"
  value       = "suse-ai.${module.infrastructure.instance_public_ip}.sslip.io"
}
