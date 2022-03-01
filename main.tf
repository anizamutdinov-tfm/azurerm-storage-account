data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_storage_account" "sacc" {
  location                  = data.azurerm_resource_group.rg.location
  resource_group_name       = data.azurerm_resource_group.rg.name
  name                      = format("sa%s", lower(replace(local.name_template, "/[[:^alnum:]]/", "")))
  account_kind              = "StorageV2"
  account_tier              = var.account_tier
  account_replication_type  = var.account_replication_type
  access_tier               = var.access_tier
  enable_https_traffic_only = true
  allow_blob_public_access  = var.allow_blob_public_access
  shared_access_key_enabled = var.shared_access_key_enabled
  is_hns_enabled            = var.is_hns_enabled

  blob_properties {
    versioning_enabled       = var.versioning_enabled
    last_access_time_enabled = var.last_access_time_enabled

    dynamic "cors_rule" {
      for_each = var.blob_cors_rules != null ? ["_"] : []
      content {
        allowed_headers    = var.blob_cors_rules.allowed_headers
        allowed_methods    = var.blob_cors_rules.allowed_methods
        allowed_origins    = var.blob_cors_rules.allowed_origins
        exposed_headers    = var.blob_cors_rules.exposed_headers
        max_age_in_seconds = var.blob_cors_rules.max_age_in_seconds
      }
    }

    dynamic "delete_retention_policy" {
      for_each = var.blob_delete_retention_policy != null ? ["_"] : []
      content {
        days = var.blob_delete_retention_policy
      }
    }

    dynamic "container_delete_retention_policy" {
      for_each = var.container_delete_retention_policy != null ? ["_"] : []
      content {
        days = var.container_delete_retention_policy
      }
    }
  }

  dynamic "custom_domain" {
    for_each = var.custom_domain != null ? ["_"] : []
    content {
      name          = var.custom_domain.name
      use_subdomain = var.custom_domain.use_subdomain
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? ["_"] : []
    content {
      default_action             = "Deny"
      virtual_network_subnet_ids = var.network_rules.subnet_ids
      ip_rules                   = var.network_rules.ip_rules
      bypass                     = var.network_rules.bypass
    }
  }

  tags = merge(local.tags, var.custom_tags)
}

resource "azurerm_storage_management_policy" "storage" {
  count = length(var.lifecycles) == 0 ? 0 : 1

  storage_account_id = azurerm_storage_account.sacc.id

  dynamic "rule" {
    for_each = var.lifecycles
    iterator = rule
    content {
      name    = format("rule%02d", rule.key)
      enabled = true
      filters {
        prefix_match = rule.value.prefix_match
        blob_types   = ["blockBlob"]
      }
      actions {
        base_blob {
          tier_to_cool_after_days_since_modification_greater_than    = rule.value.cool_after_days
          tier_to_archive_after_days_since_modification_greater_than = rule.value.archive_after_days
          delete_after_days_since_modification_greater_than          = rule.value.delete_after_days
        }
      }
    }
  }
}
