terraform{
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "5.10.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "rg-backend-storage"
        storage_account_name = "backendstorage102026"  # <- use module output
        container_name       = "statefile-container"
        key                  = "utstate.tf"  
    }
}

provider "azurerm" {
  features {}
}