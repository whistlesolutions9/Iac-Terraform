terraform {

  required_version = ">= 0.11"

  backend "azurerm" {

    storage_account_name = "__terraformstorageaccount__"

    container_name = "terraform"

    key = "terraform.tfstate"

    access_key = "__storagekey__"

  }
}



resource "azurerm_resource_group" "rg" {
  name     = "__resource_group__"
  location = "__location__"
}


resource "azurerm_storage_account" "functions_storage" {
  name                     = "__functions_storage__"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "functions_appservice"{
  name                = "__functions_appservice__"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  kind                = "FunctionApp"

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}



resource "azurerm_application_insights" "functions_appinsights"{
  name                = "__functions_appinsights__"
  location            = "${azurerm_resource_group.rg.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  application_type    = "Web"
}


resource "azurerm_function_app" "function_app" {
  name                      = "__viszleplate_functions__"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  app_service_plan_id       = "${azurerm_app_service_plan.functions_appservice.id}"
  storage_connection_string = "${azurerm_storage_account.functions_storage.primary_connection_string}"

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.functions_appinsights.instrumentation_key}"
  }
}


