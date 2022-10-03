
# Generate a random integer to create a globally unique name
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}
# el grupo de recurso lo debemos definir para agrupar los servicios que vamos
# a usar. 
# Create the resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group_name_prefix}${random_integer.ri.result}"
  location = "${var.resource_group_location}"
}

# para usar una web app o un mobile APP usamos un plan de servicio para ejecutar
# dichas aplicaciones, para dar las especificaciones del recurso azure service plan 
# se usa  el tipo de recurso azurerm service plan
# Create the  App Service Plan
resource "azurerm_service_plan" "appserviceplan" {
  name                = "${var.app_service_plan_prefix}${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Windows"

  sku_name = "S2"
}

# anteriormente se usaba azure_app_service pero por buenas practicas ya no se usa
# en cambio se usa azurerm_windows_web_app o azurerm_linux_web_app
# Create the web app, pass in the App Service Plan ID
resource "azurerm_windows_web_app" "webapp" {
  name                  = "${var.web_app_prefix}${random_integer.ri.result}"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  service_plan_id       = azurerm_service_plan.appserviceplan.id
  https_only            = true
  site_config {  
    minimum_tls_version = "1.2"
  }
}

# implementacion del azurerm_application_inisights
# nos permite usar herramientas para el monitoreo del rendimiento 
resource "azurerm_application_insights" "azai" {
  name                = "${var.application_insight_prefix}${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
	workspace_id        = azurerm_log_analytics_workspace.azlaw.id
  application_type    = "web"
}

# implementacion del recurso azurerm_log_analytics_workspace
# analytics workspace nos sirve para ver o editar registros generados
# por el monitor para saber a fondo que sucede con nuestros recursos.
resource "azurerm_log_analytics_workspace" "azlaw" {
  name                = "${var.log_analytics_workspace_prefix}${random_integer.ri.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

#  Deploy code from a public GitHub repo
resource "azurerm_app_service_source_control" "sourcecontrol" {
  app_id             = azurerm_windows_web_app.webapp.id
  repo_url           = "https://github.com/iukion/CopaHackathon_html_base"
  branch             = "master"
  use_manual_integration = true
  use_mercurial      = false
}
