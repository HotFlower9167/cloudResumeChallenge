resource "azurerm_resource_group" "rg-terra" {
  name = "rg-tfstate-${random_pet.deploymentID.id}"
  location = var.region
  tags = var.tags
}

resource "azurerm_storage_account" "sa-terra" {
  name                     = "satfstate${random_pet.deploymentID.id}${local.shortened_region}"
  resource_group_name      = azurerm_resource_group.rg-terra.name
  location                 = azurerm_resource_group.rg-terra.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  tags = var.tags
  
}

resource "azurerm_storage_container" "container-terra" {
  name                  = "tfstate"
  storage_account_id = azurerm_storage_account.sa-terra.id
  container_access_type = "private"
}