variable "lb_name" {
    description = "Nombre único para el ALB"
    type        = string
}

variable "lb_internal" {
    description = "Define si el Load Balancer debe ser interno (true) o de cara a Internet (false)"
    type        = bool
}

variable "subnet_ids" {
    description = "Lista de IDs de subredes donde se desplegará el ALB (mínimo 2, en diferentes AZs)"
    type        = list(string)
}

variable "security_group_ids" {
    description = "Lista de IDs de Security Groups para adjuntar al ALB"
    type        = list(string)
}

variable "target_group_name" {
    description = "Nombre único para el Target Group."
    type        = string
}

variable "target_group_port" {
    description = "Puerto en el que el Target Group escucha el tráfico"
    type        = number
    default     = 80
}

variable "vpc_id" {
    description = "ID de la VPC donde se desplegarán el ALB y el Target Group"
    type        = string
}


variable "health_check_path" {
    description = "Ruta HTTP utilizada para la verificación de salud de las instancias (e.g., '/health')"
    type        = string
    default     = "/health"
}

variable "health_check_matcher" {
description = "Código de estado HTTP que indica que la instancia está saludable"
type        = string
default     = "200"
}