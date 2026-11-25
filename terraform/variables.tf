variable "region" {
  description = "Resource group region"
  type        = string
  default     = "germanywestcentral"
}

variable "project_name" {
  description = "Shortened project name used in prefixes"
  type        = string
  default     = "azl"
}

variable "vnet_address_space" {
  description = "Address space for the VNET"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_space" {
  description = "Map of CIDR prefixes according to the subnet"
  type = map(object({
    address_prefixes = list(string)
  }))
  default = {
    DMZ     = { address_prefixes = ["10.0.1.0/24"] }
    LAN     = { address_prefixes = ["10.0.2.0/24"] }
    gateway = { address_prefixes = ["10.0.3.0/24"] }
  }
}