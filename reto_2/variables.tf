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

variable "resource_group" {
	type        = list(string)
	default     = [ "East US 2", "RG-PROD-01"]
	description = "Informacion referente al resource group"
}

variable "virtual_network" {
	type        = list(string)
	default     = ["VNET-PROD", "10.150.0.0/16"]
	description = "Informacion de la red virtual [nombnre, RED/CIDR]"
}

variable "subnet" {
	type        = list(string)
	default     = ["Subnet-01", "10.150.0.0/24"]
	description = "Informacion de la subred [nombre, RED/CIDR]"
}

variable "public_ip_names" {
	type        = list(string)
	default     = ["PIP-SRV-PROD-01-AZ", "PIP-SRV-PROD-02-AZ"]
	description = "Nombres de las Public IP"
}

variable "virtual_machine_names" {
	type        = list(string)
	default     = ["SRV-PROD-01-AZ", "SRV-PROD-02-AZ"]
	description = "Nombres de las VM [windows, linux]"
}

