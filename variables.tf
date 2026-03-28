variable "project_name" {
  description = "Short project identifier used for naming and tagging."
  type        = string
}

variable "environment" {
  description = "Environment name, such as dev or prod."
  type        = string
}

variable "location" {
  description = "Azure region for the VNet resources."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group that will contain the VNet."
  type        = string
}

variable "address_space" {
  description = "CIDR blocks assigned to the virtual network."
  type        = list(string)
}

variable "subnets" {
  description = "Subnet definitions keyed by logical subnet name."
  type = map(object({
    address_prefixes  = list(string)
    service_endpoints = optional(list(string), [])
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string), [])
      })
    }))
    nsg_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string, "*")
      destination_port_ranges    = list(string)
      source_address_prefixes    = list(string)
      destination_address_prefix = optional(string, "*")
      description                = optional(string)
    })), [])
  }))
}

variable "tags" {
  description = "Additional tags merged with enforced module tags."
  type        = map(string)
  default     = {}
}

variable "ddos_protection_plan_id" {
  description = "Optional Azure DDoS protection plan ID to attach to the VNet."
  type        = string
  default     = null
}
