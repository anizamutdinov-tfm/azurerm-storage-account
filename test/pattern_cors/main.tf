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
  blob_cors_rules = {
    allowed_headers    = ["Content-Type", "Accept", "Authorization", "Partition"]
    allowed_methods    = ["GET"]
    allowed_origins    = ["site.example.net", "my.example.net"]
    exposed_headers    = ["Accept"]
    max_age_in_seconds = 0
  }
}