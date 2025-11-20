variable "name" {
    description = "Nombre del Security Group."
    type        = string
}

variable "description" {
    description = "Descripción del Security Group."
    type        = string
    default     = ""
}

variable "vpc_id" {
    description = "ID de la VPC donde se creará el Security Group."
    type        = string
}