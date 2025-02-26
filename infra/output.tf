output "cosmos_db_endpoint" {
  value = azurerm_cosmosdb_account.cosmos01.endpoint
}

output "cosmos_db_key" {
  sensitive = true
  value = azurerm_cosmosdb_account.cosmos01.primary_key
}