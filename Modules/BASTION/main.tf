data "azurerm_subnet" "data-subnet" {
    for_each = var.var-bastion
    name                 = each.value.bastion-subnet-name
    virtual_network_name = each.value.virtual_network_name
    resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "data-pubip" {
    for_each = var.var-bastion
  name                = each.value.bastion-pubip-name
  resource_group_name = each.value.resource_group_name
}


resource "azurerm_bastion_host" "prod-bastion" {
  for_each = var.var-bastion
  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                 = each.value.bastion-ip-config
    subnet_id            = data.azurerm_subnet.data-subnet[each.key].id
    public_ip_address_id = data.azurerm_public_ip.data-pubip[each.key].id
  }
}