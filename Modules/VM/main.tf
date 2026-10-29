data "azurerm_key_vault" "kv" {
  for_each            = var.var-vm
  name                = each.value.keyvault-name
  resource_group_name = each.value.resource_group_name
}

data "azurerm_key_vault_secret" "vm_username" {
  for_each = var.var-vm
  name         = each.value.vault-name
  key_vault_id = data.azurerm_key_vault.kv[each.key].id
}

data "azurerm_key_vault_secret" "vm_password" {
  for_each = var.var-vm
  name         = each.value.vault-pass
  key_vault_id = data.azurerm_key_vault.kv[each.key].id
}

data "azurerm_subnet" "data-subnet" {
    for_each = var.var-vm
    name                 = each.value.subnet-name
    virtual_network_name = each.value.virtual_network_name
    resource_group_name  = each.value.resource_group_name
}

data "azurerm_public_ip" "data-pubip" {
    for_each = var.var-vm
  name                = each.value.pubip-name
  resource_group_name = each.value.resource_group_name
}

resource "azurerm_network_interface" "prod-nic" {
    for_each = var.var-vm
  name                = each.value.nic-name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name

  ip_configuration {
    name                          = each.value.ipconf-name
    subnet_id                     = data.azurerm_subnet.data-subnet[each.key].id
    private_ip_address_allocation = each.value.private_ip_address_allocation
    public_ip_address_id          = data.azurerm_public_ip.data-pubip[each.key].id
  }
}

resource "azurerm_virtual_machine" "main" {
    for_each = var.var-vm
  name                  = each.value.vm-name
  location              = each.value.location
  resource_group_name   = each.value.resource_group_name
  network_interface_ids = [azurerm_network_interface.prod-nic[each.key].id]
  vm_size               = each.value.vm_size

  storage_image_reference {
    publisher = each.value.publisher
    offer     = each.value.offer
    sku       = each.value.sku
    version   = each.value.version
  }
  storage_os_disk {
    name              = each.value.disk-name
    caching           = each.value.caching
    create_option     = each.value.create_option
    managed_disk_type = each.value.managed_disk_type
  }
  os_profile {
    computer_name  = each.value.computer_name
    admin_username = data.azurerm_key_vault_secret.vm_username[each.key].value
    admin_password = data.azurerm_key_vault_secret.vm_password[each.key].value
  }
  os_profile_linux_config {
    disable_password_authentication = each.value.disable_password_authentication
  }
}

