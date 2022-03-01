variable "resource_group_name" {
  description = "Resource group name to allocate virtual network"
  type        = string
}

variable "environment" {
  description = "Project environment"
  type        = string
}

variable "module" {
  description = "Project module name"
  type        = string
}

variable "slot" {
  description = "Project slot name. Available values: shared, blue, green"
  type        = string
}

variable "account_tier" {
  description = "Defines the Tier to use for this storage account. Valid options are Standard and Premium"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Defines the type of replication to use for this storage account. Valid options are LRS, GRS, RAGRS, ZRS, GZRS and RAGZRS"
  type        = string
  default     = "LRS"
}

variable "access_tier" {
  description = "Defines the access tier for BlobStorage, FileStorage and StorageV2 accounts. Valid options are Hot and Cool"
  type        = string
  default     = "Hot"
}

variable "shared_access_key_enabled" {
  description = "Allow or disallow public access to all blobs or containers in the storage account"
  type        = bool
  default     = true
}

variable "allow_blob_public_access" {
  description = "Indicates whether the storage account permits requests to be authorized with the account access key via Shared Key"
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Hierarchical Namespace can be used with Azure Data Lake Storage Gen 2"
  type        = bool
  default     = false
}

variable "versioning_enabled" {
  description = "Is versioning enabled?."
  type        = bool
  default     = false
}

variable "blob_cors_rules" {
  description = "CORS rules for public accessed blobs"
  type = object({
    allowed_headers    = list(string)
    allowed_methods    = list(string)
    allowed_origins    = list(string)
    exposed_headers    = list(string)
    max_age_in_seconds = number
  })
  default = null
}

variable "blob_delete_retention_policy" {
  description = " Specifies the number of days that the blob should be retained, between 1 and 365"
  type        = number
  default     = null
}

variable "container_delete_retention_policy" {
  description = " Specifies the number of days that the container should be retained, between 1 and 365"
  type        = number
  default     = null
}

variable "last_access_time_enabled" {
  description = "Is the last access time based tracking enabled?"
  type        = bool
  default     = false
}

variable "custom_domain" {
  type = object({
    name          = string
    use_subdomain = bool
  })
  default = null
}

variable "network_rules" {
  description = "Network rules restricting access to the storage account."
  type = object({
    ip_rules   = list(string)
    subnet_ids = list(string)
    bypass     = list(string)
  })
  default = null
}

variable "lifecycles" {
  description = "List of lifecycle delete"
  type = list(object({
    prefix_match       = set(string)
    delete_after_days  = number
    cool_after_days    = number
    archive_after_days = number
  }))
  default = []
}

variable "custom_tags" {
  description = "Custom tags to add"
  type        = map(string)
  default     = {}
}
