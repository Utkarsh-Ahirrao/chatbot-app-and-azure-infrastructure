terraform{
    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
            version = "5.10.0"
        }
    }
    backend "azurerm" {
        resource_group_name  = "back-stg"
        storage_account_name = "ut007backupstg"  # <- use module output
        container_name       = "backupset"
        key                  = "terraformbackup.tfstate"  
    }
}

provider "azurerm" {
  features {}
}