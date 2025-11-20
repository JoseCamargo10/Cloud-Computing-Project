variable "vpc_id" {
    description = "ID de la VPC donde se usará el IGW"
    type        = string
}

variable "name" {
    description = "Nombre del IGW"
    type        = optional(string)
    default = ""
}