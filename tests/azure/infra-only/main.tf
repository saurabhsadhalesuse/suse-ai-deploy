locals {
  location             = "West US 2"
  ssh_private_key_path = "${path.cwd}/${var.prefix}-ssh_private_key.pem"
  ssh_public_key_path  = "${path.cwd}/${var.prefix}-ssh_public_key.pem"
  instance_type        = "Standard_NC4as_T4_v3"
}

module "azure_infrastructure" {
  source                     = "../../../modules/infrastructure/azure"
  prefix                     = var.prefix
  location                   = local.location
  ssh_private_key_path       = local.ssh_private_key_path
  ssh_public_key_path        = local.ssh_public_key_path
  instance_type              = local.instance_type
  subscription_id            = var.subscription_id
  public_ip_source_addresses = var.public_ip_source_addresses
}
