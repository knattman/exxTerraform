data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "key_vault" {
  name                        = "webserver-demo-key-vault"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Get", "Create", "List", "Delete", "Purge"
    ]

    secret_permissions = [
      "Get", "Set", "List", "Delete", "Purge"
    ]

    storage_permissions = [
      "Get", "Set", "List", "Delete", "Purge"
    ]
  }
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "azurerm_key_vault_secret" "demoadmin-password" {
  name         = "demoadmin-password"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.key_vault.id
}

data "azurerm_key_vault_secret" "demoadmin" {
  name         = "demoadmin-password"
  key_vault_id = azurerm_key_vault.key_vault.id
  depends_on   = [azurerm_key_vault_secret.demoadmin-password]
}
