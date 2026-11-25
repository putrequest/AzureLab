output "DMZ_name" {
  description = "Name of DMZ subnet"
  value       = azurerm_subnet.DMZ.name
}

output "DMZ_address_range" {
  description = "DMZ subnet address range"
  value       = azurerm_subnet.DMZ.address_prefixes
}

output "LAN_name" {
  description = "Name of LAN subnet"
  value       = azurerm_subnet.LAN.name
}

output "LAN_address_range" {
  description = "LAN subnet address range"
  value       = azurerm_subnet.LAN.address_prefixes
}

output "gateway_name" {
  description = "Name of gateway subnet"
  value       = azurerm_subnet.gateway.name
}

output "gateway_address_range" {
  description = "Gateway subnet address range"
  value       = azurerm_subnet.gateway.address_prefixes
}