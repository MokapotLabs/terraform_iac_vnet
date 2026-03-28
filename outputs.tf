output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "resource_group_name" {
  description = "Resource group that contains the virtual network."
  value       = var.resource_group_name
}

output "subnet_ids" {
  description = "Subnet IDs keyed by logical subnet name."
  value = {
    for subnet_name, subnet in azurerm_subnet.this : subnet_name => subnet.id
  }
}

output "nsg_ids" {
  description = "Network security group IDs keyed by logical subnet name."
  value = {
    for subnet_name, subnet in var.subnets : subnet_name => try(azurerm_network_security_group.this[subnet_name].id, null)
  }
}
