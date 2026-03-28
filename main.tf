locals {
  common_tags = merge(var.tags, {
    environment = var.environment
    location    = var.location
    managed_by  = "terraform"
    project     = var.project_name
  })

  nsg_enabled_subnets = {
    for subnet_name, subnet in var.subnets : subnet_name => subnet
    if length(try(subnet.nsg_rules, [])) > 0
  }

  nsg_rules = merge(
    {},
    [
      for subnet_name, subnet in local.nsg_enabled_subnets : {
        for rule in subnet.nsg_rules : "${subnet_name}.${rule.name}" => merge(rule, {
          subnet_name = subnet_name
        })
      }
    ]...
  )
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.project_name}-${var.environment}-${var.location}"
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = local.common_tags

  dynamic "ddos_protection_plan" {
    for_each = var.ddos_protection_plan_id == null ? [] : [var.ddos_protection_plan_id]

    content {
      id     = ddos_protection_plan.value
      enable = true
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = "snet-${var.project_name}-${var.environment}-${each.key}"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = try(each.value.service_endpoints, [])

  dynamic "delegation" {
    for_each = try(each.value.delegation, null) == null ? [] : [each.value.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation.name
        actions = try(delegation.value.service_delegation.actions, [])
      }
    }
  }
}

resource "azurerm_network_security_group" "this" {
  for_each = local.nsg_enabled_subnets

  name                = "nsg-${var.project_name}-${var.environment}-${each.key}"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags
}

resource "azurerm_network_security_rule" "this" {
  for_each = local.nsg_rules

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = try(each.value.source_port_range, "*")
  destination_port_ranges     = each.value.destination_port_ranges
  source_address_prefixes     = each.value.source_address_prefixes
  destination_address_prefix  = try(each.value.destination_address_prefix, "*")
  description                 = try(each.value.description, null)
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this[each.value.subnet_name].name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = local.nsg_enabled_subnets

  subnet_id                 = azurerm_subnet.this[each.key].id
  network_security_group_id = azurerm_network_security_group.this[each.key].id
}
