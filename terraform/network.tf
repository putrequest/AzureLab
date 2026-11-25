resource "azurerm_virtual_network" "main" {
  name                = "${var.project_name}-vnet"
  resource_group_name = "${var.project_name}-rg"
  location            = var.region
  address_space       = var.vnet_address_space
}

resource "azurerm_subnet" "DMZ" {
  name                 = "DMZ-subnet"
  resource_group_name  = "${var.project_name}-rg"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_space["DMZ"].address_prefixes

}

resource "azurerm_subnet" "LAN" {
  name                 = "LAN-subnet"
  resource_group_name  = "${var.project_name}-rg"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_space["LAN"].address_prefixes
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway-subnet"
  resource_group_name  = "${var.project_name}-rg"
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = var.subnet_address_space["gateway"].address_prefixes
}

resource "azurerm_network_security_group" "DMZ-nsg" {
  name                = "DMZ-nsg"
  location            = var.region
  resource_group_name = "${var.project_name}-rg"
}

resource "azurerm_network_security_group" "LAN-nsg" {
  name                = "LAN-nsg"
  location            = var.region
  resource_group_name = "${var.project_name}-rg"
}

resource "azurerm_network_security_group" "gateway-nsg" {
  name                = "gateway-nsg"
  location            = var.region
  resource_group_name = "${var.project_name}-rg"
}
resource "azurerm_subnet_network_security_group_association" "DMZ-nsg-assoc" {
  subnet_id                 = azurerm_subnet.DMZ.id
  network_security_group_id = azurerm_network_security_group.DMZ-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "LAN-nsg-assoc" {
  subnet_id                 = azurerm_subnet.LAN.id
  network_security_group_id = azurerm_network_security_group.LAN-nsg.id
}

resource "azurerm_subnet_network_security_group_association" "gateway-nsg-assoc" {
  subnet_id                 = azurerm_subnet.gateway.id
  network_security_group_id = azurerm_network_security_group.gateway-nsg.id
}