terraform {
  backend "azurerm" {} 
  required_providers {
    azurerm = {
      version = "= 3.25.0"
    }
  }
}

provider "azurerm" {
  features {}
  use_oidc = true
}

data "azurerm_client_config" "current" {}

data "http" "ip" {
  url = "https://ifconfig.me"
}