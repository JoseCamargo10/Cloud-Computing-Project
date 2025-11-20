variable "routes" {
    description = "Mapa de objetos para definir rutas adicionales con targets opcionales."
    type = map(object({
        cidr_block     = string             # Destino de la ruta (e.g., '0.0.0.0/0')
        gateway_id     = optional(string)   # ID del Internet Gateway
        nat_gateway_id = optional(string)   # ID del NAT Gateway
    }))
    default = {}
}

variable "vpc_id" {
    description = "ID de la VPC donde se creará la tabla de rutas."
    type        = string
}

variable "name" {
    description = "Nombre para la tabla de rutas."
    type        = string
}

variable "subnet_id" {
    description = "ID de la subred a la que se asociará la route table"
    type        = string
}