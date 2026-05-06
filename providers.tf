terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-rg"
    storage_account_name = "tfstorage552026"
    container_name       = "tf-container"
    key                  = "prod.terraform.tfstate"
  }
}


provider "azurerm" {
  features {}
}
