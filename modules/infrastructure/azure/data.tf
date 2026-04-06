data "azurerm_subscription" "current" {}

data "azurerm_platform_image" "opensuse_leap" {
  location  = var.location
  publisher = "SUSE"
  offer     = "opensuse-leap-15-6"
  sku       = "gen2"
}

data "azurerm_location" "current" {
  location = var.location
}
