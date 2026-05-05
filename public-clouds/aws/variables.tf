variable "prefix" {
  type    = string
  default = "aws-tf"
}

variable "region" {
  type    = string
  default = "us-west-2"
}

variable "zone" {
  type    = string
  default = "us-west-2a"
}

variable "instance_type" {
  type    = string
  default = "g4dn.xlarge"
}

variable "os_disk_size" {
  type    = number
  default = 150
}

variable "ssh_username" {
  description = "The default SSH user for the AMI"
  type        = string
  default     = "opensuse" # Default for custom build image for suse-ai-tf
}

variable "create_ssh_key_pair" {
  type    = bool
  default = true
}

variable "ssh_private_key_path" {
  type    = string
  default = null
}

variable "ssh_public_key_path" {
  type    = string
  default = null
}

variable "existing_key_name" {
  type    = string
  default = ""
}

variable "use_existing_vpc" {
  type    = bool
  default = false
}

variable "vpc_id" {
  description = "Existing VPC ID (leave null if creating a new VPC)"
  type        = string
  default     = null

  # Case 1: require vpc_id when using existing VPC
  validation {
    condition     = var.use_existing_vpc == false || var.vpc_id != null
    error_message = "vpc_id must be provided when use_existing_vpc is true."
  }
}

variable "subnet_id" {
  description = "Existing Subnet ID (leave null if creating a new subnet)"
  type        = string
  default     = null

  # Case 1: require vpc_id when using existing VPC
  validation {
    condition     = var.use_existing_vpc == false || var.subnet_id != null
    error_message = "subnet_id must be provided when use_existing_vpc is true."
  }
}

variable "ip_cidr_range" {
  type    = string
  default = "10.0.1.0/24"
}

variable "rke2_version" {
  type    = string
  default = "v1.30.2+rke2r1"
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

variable "deployer_chart_version" {
  type        = string
  description = "Chart version for the suse-ai-deployer helmchart"
  default     = "1.2.0"
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

variable "certified_os_image_tag" {
  description = "Specifies which GitHub release to use for the OpenSUSE image. Default is 'build-1'."
  type        = string
  default     = "build-11"
  validation {
    condition     = can(regex("^build-[0-9]+$", var.certified_os_image_tag))
    error_message = "Invalid value for certified_os_image_tag. Allowed values must match the format 'build-<number>'."
  }
}

variable "public_ip_source_addresses" {
  description = "List of CIDRs allowed to reach port 22 (SSH). Defaults to the public IP of the machine running Terraform. Override with a specific CIDR or '0.0.0.0/0' to allow all."
  type        = list(string)
  default     = []
}
