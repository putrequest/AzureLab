locals {
  resource_name = var.project_name
}

resource "azurerm_resource_group" "azl_resource_group" {
  name     = "${local.resource_name}-rg"
  location = var.region
}
