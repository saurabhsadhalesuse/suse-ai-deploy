variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'suseaiinfratest'."
  type        = string
  default     = "suseainfratest"
}

variable "project_id" {
  description = "Specifies the project ID for your Google cloud account."
  type        = string
  default     = null
}

variable "public_ip_source_addresses" {
  type        = list(string)
  description = "List of public IP addresses allowed to access the resources"
}
