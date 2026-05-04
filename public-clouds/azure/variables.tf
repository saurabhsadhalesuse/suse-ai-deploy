variable "prefix" {
  description = "Prefix for all resources to ensure uniqueness"
  type        = string
  default     = "azure-tf"
}

variable "location" {
  description = "Azure region to deploy into"
  type        = string
  default     = "West US 2" # Equivalent to us-west-2
}

variable "zone" {
  description = "Availability zone for the instance (Azure uses '1', '2', or '3')"
  type        = string
  default     = "1"
}

variable "instance_type" {
  description = "VM size (must support GPUs). Standard_NC4as_T4_v3 is the T4 equivalent."
  type        = string
  default     = "Standard_NC4as_T4_v3"
}

variable "os_disk_size" {
  description = "Size of the root OS disk in GB"
  type        = number
  default     = 150
}

variable "ssh_username" {
  type    = string
  default = "azureuser"
}

variable "create_ssh_key_pair" {
  description = "Whether to generate a new SSH key pair"
  type        = bool
  default     = true
}

variable "ssh_private_key_path" {
  description = "Path to save/read the private key (null for default naming)"
  type        = string
  default     = null
}

variable "ssh_public_key_path" {
  description = "Path to save/read the public key (null for default naming)"
  type        = string
  default     = null
}

# Not strictly needed for the simplified Azure module but kept for AWS parity
variable "existing_key_name" {
  type    = string
  default = null
}

variable "vnet_id" {
  description = "Existing Virtual Network ID (leave null if creating a new VNet)"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Existing Subnet ID (leave null if creating a new subnet)"
  type        = string
  default     = null
}

variable "rke2_version" {
  description = "The version of RKE2 to install"
  type        = string
  default     = "v1.30.2+rke2r1"
}

variable "deployer_chart_version" {
  type        = string
  description = "Chart version for the suse-ai-deployer helmchart"
  default     = "1.2.0"
}

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "certified_os_image_tag" {
  description = "Specifies which GitHub release to use for the SUSE AI TF Custom build OpenSUSE image. Default is 'build-11'."
  type        = string
  default     = "build-11"
  validation {
    condition     = can(regex("^build-[0-9]+$", var.certified_os_image_tag))
    error_message = "Invalid value for certified_os_image_tag. Allowed values must match the format 'build-<number>'."
  }
}

variable "rancher_api_url" {
  description = "Specifies the Rancher API endpoint used to manage the SUSE AI cluster. Default is empty."
  type        = string
  default     = ""
}

variable "rancher_access_key" {
  description = "Specifies the Rancher access key for authentication. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "rancher_secret_key" {
  description = "Specifies the Rancher secret key for authentication. Default is empty."
  type        = string
  default     = ""
  sensitive   = true
}

variable "rancher_insecure" {
  description = "Specifies whether to allow insecure connections to the Rancher API. Default is 'false'."
  type        = bool
  default     = false
}

variable "registry_name" {
  type        = string
  default     = "dp.apps.rancher.io"
  description = "Name of the application collection registry"
}

variable "registry_secretname" {
  type        = string
  default     = "application-collection"
  description = "Name of the secret for accessing the registry"
}

variable "registry_username" {
  type        = string
  description = "Username for the registry"
}

variable "registry_password" {
  type        = string
  description = "Password/Token for the registry"
  sensitive   = true
}

variable "suse_ai_namespace" {
  type        = string
  default     = "suse-ai"
  description = "Name of the namespace where you want to deploy SUSE AI Stack!"
}

variable "cert_manager_namespace" {
  type        = string
  default     = "cert-manager"
  description = "Name of the namespace where you want to deploy cert-manager"
}

variable "gpu_operator_ns" {
  type        = string
  description = "Namespace for the NVIDIA GPU operator"
  default     = "gpu-operator"
}
