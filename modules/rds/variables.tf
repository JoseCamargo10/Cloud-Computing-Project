variable "db_name" {
  description = "Nombre de la base de datos dentro del cluster."
  type        = string
}

variable "db_username" {
  description = "Nombre de usuario maestro para la base de datos."
  type        = string
}

variable "db_password" {
  description = "Contraseña maestra para la base de datos. ¡Usar un secreto!"
  type        = string
  sensitive   = true # Marca como sensible para no mostrar en logs
}

variable "vpc_security_group_ids" {
  description = "Lista de IDs de Security Groups para adjuntar al cluster."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Lista de IDs de subredes privadas para el cluster DB."
  type        = list(string)
}