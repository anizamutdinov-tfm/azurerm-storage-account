terraform {
  backend "local" {}
}
provider "azurerm" {
  features {}
}

locals {
  location    = "westeurope"
  environment = "test"
  module      = "app-007"
  slot        = "shared"
}

module "rg" {
  source      = "git@github.com:anizamutdinov-tfm/azurerm-resource-group.git"
  location    = local.location
  environment = local.environment
  module      = local.module
  slot        = local.slot
  custom_tags = { special_tag = "special_value" }
}

module "storage_account" {
  source              = "../../"
  depends_on          = [module.rg]
  resource_group_name = module.rg.resource_group_name
  environment         = local.environment
  module              = local.module
  slot                = local.slot

  network_rules = {
    bypass     = ["Logging", "Metrics", "AzureServices"]
    subnet_ids = []
    ip_rules   = ["8.8.8.8"]
  }
}