// Deploy the Azure Cosmos DB
resource "azurerm_cosmosdb_account" "cosmos01" {
  name = "cosno-${random_pet.deploymentID.id}-${local.shortened_region}"
  location = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  offer_type = "Standard"
  kind = "GlobalDocumentDB"
  free_tier_enabled = true
  geo_location {
    location = azurerm_resource_group.rg01.location
    failover_priority = 0
  }
  consistency_policy {
    consistency_level = "Eventual"
  }
  tags = var.tags
}

// Deploy the Azure Cosmos DB database
resource "azurerm_cosmosdb_sql_database" "cosmosdb01" {
  name = var.COSMOS_DB_NAME
  resource_group_name = azurerm_resource_group.rg01.name
  account_name = azurerm_cosmosdb_account.cosmos01.name
}

//Deploy the Azure Cosmos DB container
resource "azurerm_cosmosdb_sql_container" "cosmosdbcontainer01" {
  name = var.COSMOS_DB_CONTAINER
  resource_group_name = azurerm_resource_group.rg01.name
  account_name = azurerm_cosmosdb_account.cosmos01.name
  database_name = azurerm_cosmosdb_sql_database.cosmosdb01.name
  partition_key_paths = ["/id"]
  partition_key_version = 1
}