variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'suseaiinfratest'."
  type        = string
  default     = "suseainfratest"
}

variable "subscription_id" {
  description = "Specifies the Azure account subscription ID"
  type        = string
}

variable "public_ip_source_addresses" {
  type        = list(string)
  description = "List of public IP addresses allowed to access the resources"
}
