resource "azurerm_virtual_network" "prod-vnet" {
    for_each = var.var-vnet
    name = each.value.name
    location = each.value.location
    resource_group_name = each.value.resource_group_name
    address_space = each.value.address_space
}