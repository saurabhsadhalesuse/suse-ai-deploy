data "azurerm_subscription" "current" {}

data "azurerm_location" "current" {
  location = var.location
}
