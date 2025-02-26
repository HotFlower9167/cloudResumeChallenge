variable "subscription_id" {
  description = "Azure Subscription ID"
}

variable "region" {
  description = "Azure Region"
  default = "northeurope"
  
}

variable "COSMOS_DB_NAME" {
  description = "Cosmos DB Name"
  default = "cloudresumechallengeDB"
  
}

variable "COSMOS_DB_CONTAINER" {
  description = "Cosmos DB Container"
  default = "cloudresumechallenge"
  
}

variable "tags" {
  description = "Tags to apply to all resources"
  type = map(string)
  default = {
    environment = "dev"
    project = "cloudresumechallenge"
    owner = "HotFlower"
  }
  
}