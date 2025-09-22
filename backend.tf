terraform {
  backend "azurerm" {
    resource_group_name  = "rg-hub-weu-prod"
    storage_account_name = "stky0qhub"
    container_name       = "tfstate"
    key                  = "tyrant/${environment}.tfstate"
    subscription_id      = var.subscription_id
  }
}