resource "random_pet" "deploymentID" {
  length = 2
  separator = ""
  }

resource "random_string" "randomDeploymentString" {
  length = 4
  special = false
  upper = false
  
}

data "azurerm_client_config" "current" {
}

// Shortens the region name, the JSON list comes from https://github.com/Azure/terraform-azurerm-caf-enterprise-scale/blob/main/modules/connectivity/locals.geo_codes.tf.json
locals {
  region_map = jsondecode(file("${path.module}/azureRegions.json"))
  shortened_region = lookup(local.region_map, var.region, var.region) # Fallback to original if not found
}

// Deploy the resource group
resource "azurerm_resource_group" "rg01" {
  name = "rg-${random_pet.deploymentID.id}-${local.shortened_region}"
  location = var.region
  tags = var.tags
}

// Deploy the storage account required by the Azure Function
resource "azurerm_storage_account" "sa01" {
  name                     = "sa${random_pet.deploymentID.id}${random_string.randomDeploymentString.result}${local.shortened_region}"
  resource_group_name      = azurerm_resource_group.rg01.name
  location                 = azurerm_resource_group.rg01.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags = var.tags
}

// Deploy the log analytics workspace
resource "azurerm_log_analytics_workspace" "log01" {
  name                = "log-${random_pet.deploymentID.id}-${local.shortened_region}"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  sku                 = "PerGB2018"
  tags = var.tags
}

// Deploy the Azure application insights
resource "azurerm_application_insights" "appi01" {
  name                = "appi-${random_pet.deploymentID.id}-${local.shortened_region}"
  location            = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  workspace_id = azurerm_log_analytics_workspace.log01.id
  application_type    = "web"
  tags = var.tags
}

// Deploy the app service plan
resource "azurerm_service_plan" "asp01" {
  name = "asp-${random_pet.deploymentID.id}-${local.shortened_region}"
  location = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  os_type = "Linux"
  sku_name = "Y1"
  tags = var.tags
}

// Deploy the Azure Function
resource "azurerm_linux_function_app" "fa01" {
  name= "func-${random_pet.deploymentID.id}-${local.shortened_region}"
  location = azurerm_resource_group.rg01.location
  resource_group_name = azurerm_resource_group.rg01.name
  service_plan_id = azurerm_service_plan.asp01.id
  storage_account_name = azurerm_storage_account.sa01.name
  storage_account_access_key = azurerm_storage_account.sa01.primary_access_key
  ftp_publish_basic_authentication_enabled = false
  https_only = true
  webdeploy_publish_basic_authentication_enabled = false
  site_config {
    application_stack {
      node_version = "22"
    }
    application_insights_connection_string = azurerm_application_insights.appi01.connection_string
    application_insights_key = azurerm_application_insights.appi01.instrumentation_key
  }
  identity {
    type = "SystemAssigned"
  }
  app_settings = {
    "COSMOS_DB_NAME" : "${azurerm_cosmosdb_sql_database.cosmosdb01.name}"
    "COSMOS_DB_CONTAINER" : "${azurerm_cosmosdb_sql_container.cosmosdbcontainer01.name}"
    "COSMOS_DB_ENDPOINT" : "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv01.name};SecretName=${azurerm_key_vault_secret.kvSecretCosmosDBEndpoint.name})"
    "COSMOS_DB_KEY" : "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv01.name};SecretName=${azurerm_key_vault_secret.kvSecretCosmosDBKey.name})"
    "WEBSITE_RUN_FROM_PACKAGE" : "https://saloyalvervet4agine.blob.core.windows.net/function-releases/20250222171444-946743a687d64aadf47c79621e882af2.zip?sv=2024-05-04&st=2025-02-22T17%3A09%3A51Z&se=2035-02-22T17%3A14%3A51Z&sr=b&sp=r&sig=n11h6kijLc%2B6%2FOiz18210U9EIeMTmCGp6jlKHyPvw%2Bo%3D"
  }
  lifecycle {
    ignore_changes = [ app_settings["WEBSITE_RUN_FROM_PACKAGE"] ]
  }
  
}

