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

variable "subscription_id" {
  description = "The Azure Subscription ID"
  type        = string
}

variable "certified_os_image" {
  description = "Specifies whether to use the SUSE AI TF custom build OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'false'."
  type        = bool
  default     = false
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

variable "public_ip_source_addresses" {
  description = "List of CIDRs allowed to reach port 22 (SSH). Defaults to the public IP of the machine running Terraform."
  type        = list(string)
  default     = []
}
