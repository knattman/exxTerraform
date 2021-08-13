terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.67.0"
    }
  }
}

provider "azurerm" {
  # Configuration options  
  features {}
}