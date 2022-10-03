/*
variable "variable name" {
    type        = {string|number|bool|list|map}
    default     = "si se especifica, entonces no es necesario asignarle un valor a la variable"
    description = "documentacion de la variable"
    validation  = "bloque para definir reglas de validacion, usualmente restricciones"
    sensitive   = "Para limitar el output cuando la variable es usada en la configuracion"
    nullable    = "para especificar si la variable puede tener un valor nulo"
}

 EJEMPLO # 1 declaracion de una variable de tipo string con una restriccion
variable "image_id" {
    type         = string
    description  = "El ID de la imagen de la maquina para usar en el servidor."

    validation {
        condition     = length(var.image_id) > 4 && substr(var.image_id, 0, 4) == "ami-"
        error_message = "El valor image_id debe ser un id AMI valido, empezando con \"ami-\"."
    }
}
*/

variable "resource_group_location" {
  default     = "South Central US"
  description = "Ubicacion del resource group"
}

variable "resource_group_name_prefix" {
  default     = "rg-"
  description = "Prefijo de el nombre del resource group"
}

variable "app_service_plan_prefix" {
    default     = "plan-copa-"
    description = "prefijo del app_service_plan"
}

variable "web_app_prefix" {
    default     = "app-copa-"
    description = "prefijo de la web_app"
}

variable "application_insight_prefix" {
    default     = "appi-copa-"
    description = "prefijo del application_insight"
}

variable "log_analytics_workspace_prefix" {
    default     = "log-copa-"
    description = "prefijo del log_analytics_workspace"
}

