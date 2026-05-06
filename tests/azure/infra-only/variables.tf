variable "prefix" {
  description = "Specifies the prefix added to the names of all resources. Default is 'suseaiinfratest'."
  type        = string
  default     = "suseainfratest"
}

variable "subscription_id" {
  description = "Specifies the Azure account subscription ID"
  type        = string
}

