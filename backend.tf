terraform {
  backend "azurerm" {
    resource_group_name  = "rg-hub-weu-prod"
    storage_account_name = "stky0qhub"
    container_name       = "tfstate"
    key                  = "tyrant/${var.environment}.tfstate"
  }
}