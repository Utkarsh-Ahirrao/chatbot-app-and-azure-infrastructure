rg = {
    rg1 = {
        name = "rg-prod"
        location = "centralindia"
    }
}

stgacc = {
    stg1 = {
        name = "stgacc007prod"
        location = "centralindia"
        resource_group_name = "rg-prod"
        account_tier = "Standard"
        account_replication_type = "LRS"
    }
}

vnet = {
    vnet1 = {
        name = "vnet-prod"
        location = "centralindia"
        resource_group_name = "rg-prod"
        address_space = ["15.0.0.0/16"] 
    }
}

subnet = {
    subnet1 = {
        name = "frontend-prod"
        resource_group_name = "rg-prod"
        virtual_network_name = "vnet-prod"
        address_prefixes = ["15.0.1.0/24"]
    }
    subnet2 = {
        name = "backend-prod"
        resource_group_name = "rg-prod"
        virtual_network_name = "vnet-prod"
        address_prefixes = ["15.0.2.0/24"]
    }
}

nsg = {
    nsg1 = {
        name                = "nsg-prod"
        location            = "centralindia"
        resource_group_name = "rg-prod"

        rule-name                  = "test123"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
        }
}

pubip = {
    pubip1 = {
        name = "frontip-prod"
        location = "centralindia"
        resource_group_name = "rg-prod"
        allocation_method   = "Static"
    }

    pubip2 = {
        name = "backip-prod"
        location = "centralindia"
        resource_group_name = "rg-prod"
        allocation_method   = "Static"
    }
}

vm = {
    vm1 = {
        keyvault-name = "ut-locker007"
        vault-name         = "vm-admin-username"
        vault-pass         = "vm-admin-password"

        subnet-name                 = "frontend-prod"
        virtual_network_name        = "vnet-prod"
        
        pubip-name                        = "frontip-prod"

        nic-name                = "nicfront-prod"
        location                = "centralindia"
        resource_group_name         = "rg-prod"

        ipconf-name                          = "ipconfig1"
        private_ip_address_allocation       = "Dynamic"
    
        vm-name                  = "frontvm-prod"
        vm_size               = "Standard_B2ls_v2"

        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"

        disk-name              = "frontdisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"

        computer_name  = "frontmachine"
      

        disable_password_authentication = false
    }

    vm2 = {
        keyvault-name = "ut-locker007"
        vault-name         = "vm-admin-username"
        vault-pass         = "vm-admin-password"

        subnet-name                 = "backend-prod"
        virtual_network_name        = "vnet-prod"
        
        pubip-name                        = "backip-prod"

        nic-name                = "nicback-prod"
        location                = "centralindia"
        resource_group_name         = "rg-prod"

        ipconf-name                          = "ipconfig1"
        private_ip_address_allocation       = "Dynamic"

        vm-name                  = "backvm-prod"
        vm_size               = "Standard_B2ls_v2"

        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts"
        version   = "latest"

        disk-name              = "backdisk1"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Standard_LRS"

        computer_name  = "Backmachine"
       
        disable_password_authentication = false
    }
}