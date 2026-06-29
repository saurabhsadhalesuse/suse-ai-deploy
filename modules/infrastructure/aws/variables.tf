variable "prefix" {
  description = "Prefix for all resources to ensure uniqueness"
  type        = string
  default     = "aws-tf"
}

variable "region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "zone" {
  description = "Availability zone for the instance and EBS volume"
  type        = string
  default     = "us-west-2a"
}

variable "instance_type" {
  description = "Instance type for the VM (must support GPUs, e.g., g4dn.xlarge)"
  type        = string
  default     = "g4dn.xlarge"
}

variable "os_disk_size" {
  description = "Size of the root OS disk in GB"
  type        = number
  default     = 500
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

variable "existing_key_name" {
  type    = string
  default = null
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

variable "associate_public_ip" {
  description = "Set to true if using a public subnet, false for private."
  type        = bool
  default     = true
}

variable "ip_cidr_range" {
  description = "The IP range for the subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "rke2_version" {
  description = "The version of RKE2 to install"
  type        = string
  default     = "v1.32.10+rke2r1"
}

variable "certified_os_image_tag" {
  description = "Specifies which GitHub release to use for the OpenSUSE image. Default is 'build-1'."
  type        = string
  default     = "build-1"
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

variable "ha_setup" {
  description = "Set to true for 3-node HA cluster"
  type        = bool
  default     = false
}
