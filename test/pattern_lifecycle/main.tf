terraform {
  backend "local" {}
}
provider "azurerm" {
  features {}
}

variable "slot" {
  default = ""
}

locals {
  location    = "westeurope"
  environment = "test"
  module      = "app-007"
  slot        = coalesce(var.slot, "shared")
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
  lifecycles = [
    {
      prefix_match       = ["container/path"]
      cool_after_days    = 1
      archive_after_days = 0
      delete_after_days  = 2
    },
    {
      prefix_match       = ["container/another_path"]
      cool_after_days    = 3
      archive_after_days = 0
      delete_after_days  = 5
    }
  ]
}