# VNet Module

Reusable Azure Virtual Network module with optional subnet-specific NSGs and service delegation.

## Example

```hcl
module "vnet" {
  source = "../../modules/vnet"

  project_name        = "acme"
  environment         = "dev"
  location            = "eastus"
  resource_group_name = "rg-acme-dev-eus"
  address_space       = ["10.10.0.0/16"]

  subnets = {
    workload = {
      address_prefixes  = ["10.10.1.0/24"]
      service_endpoints = ["Microsoft.Storage"]
      nsg_rules = [
        {
          name                      = "allow-ssh-admin"
          priority                  = 100
          direction                 = "Inbound"
          access                    = "Allow"
          protocol                  = "Tcp"
          destination_port_ranges   = ["22"]
          source_address_prefixes   = ["203.0.113.10/32"]
          destination_address_prefix = "*"
        }
      ]
    }
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement_azurerm) | ~> 4.20 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider_azurerm) | ~> 4.20 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_subnet.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_address_space"></a> [address_space](#input_address_space) | CIDR blocks assigned to the virtual network. | `list(string)` | n/a | yes |
| <a name="input_environment"></a> [environment](#input_environment) | Environment name, such as dev or prod. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input_location) | Azure region for the VNet resources. | `string` | n/a | yes |
| <a name="input_project_name"></a> [project_name](#input_project_name) | Short project identifier used for naming and tagging. | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource_group_name](#input_resource_group_name) | Name of the resource group that will contain the VNet. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input_subnets) | Subnet definitions keyed by logical subnet name. | <pre>map(object({<br/>    address_prefixes  = list(string)<br/>    service_endpoints = optional(list(string), [])<br/>    delegation = optional(object({<br/>      name = string<br/>      service_delegation = object({<br/>        name    = string<br/>        actions = optional(list(string), [])<br/>      })<br/>    }))<br/>    nsg_rules = optional(list(object({<br/>      name                       = string<br/>      priority                   = number<br/>      direction                  = string<br/>      access                     = string<br/>      protocol                   = string<br/>      source_port_range          = optional(string, "*")<br/>      destination_port_ranges    = list(string)<br/>      source_address_prefixes    = list(string)<br/>      destination_address_prefix = optional(string, "*")<br/>      description                = optional(string)<br/>    })), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_ddos_protection_plan_id"></a> [ddos_protection_plan_id](#input_ddos_protection_plan_id) | Optional Azure DDoS protection plan ID to attach to the VNet. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input_tags) | Additional tags merged with enforced module tags. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_nsg_ids"></a> [nsg_ids](#output_nsg_ids) | Network security group IDs keyed by logical subnet name. |
| <a name="output_resource_group_name"></a> [resource_group_name](#output_resource_group_name) | Resource group that contains the virtual network. |
| <a name="output_subnet_ids"></a> [subnet_ids](#output_subnet_ids) | Subnet IDs keyed by logical subnet name. |
| <a name="output_vnet_id"></a> [vnet_id](#output_vnet_id) | ID of the virtual network. |
| <a name="output_vnet_name"></a> [vnet_name](#output_vnet_name) | Name of the virtual network. |
<!-- END_TF_DOCS -->
