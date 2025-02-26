// Deploy the Azure Key Vault
resource "azurerm_key_vault" "kv01" {
  name = "kv-${random_pet.deploymentID.id}-${local.shortened_region}"
  location = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  sku_name = "standard"
  tenant_id = data.azurerm_client_config.current.tenant_id
  enable_rbac_authorization = true
  soft_delete_retention_days = 7
  purge_protection_enabled = false
  tags = var.tags
}

// Deploy the Azure Key Vault secret
resource "azurerm_key_vault_secret" "kvSecretCosmosDBKey" {
  name = "COSMOSDBKEY"
  key_vault_id = azurerm_key_vault.kv01.id
  value = azurerm_cosmosdb_account.cosmos01.primary_key
  lifecycle {
    ignore_changes = [value]
  }
}
resource "azurerm_key_vault_secret" "kvSecretCosmosDBEndpoint" {
  name = "COSMOSDBENDPOINT"
  key_vault_id = azurerm_key_vault.kv01.id
  value = azurerm_cosmosdb_account.cosmos01.endpoint  
  lifecycle {
    ignore_changes = [value]
  }
}

// Assign the Azure Function identity access to the Azure Key Vault using RBAC
resource "azurerm_role_assignment" "funcToKV" {
  scope = azurerm_key_vault.kv01.id
  role_definition_name = "Key Vault Secrets User"
  principal_id = azurerm_linux_function_app.fa01.identity[0].principal_id
}