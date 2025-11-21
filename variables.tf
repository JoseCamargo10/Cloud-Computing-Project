variable "ec2_role_name" {
    description = "El nombre deseado para el Rol IAM de las instancias EC2."
    type        = string
}

variable "ec2_instance_profile_name" {
    description = "El nombre deseado para el Instance Profile asociado al Rol."
    type        = string
}

variable "ec2_attached_policies" {
    description = "Lista de ARNs de políticas IAM que deben adjuntarse al Rol EC2 (ej. SSM, S3). Si está vacía, no se adjuntan políticas adicionales."
    type        = list(string)
    default     = []
}















variable "public_subnets" {
    description = "Configuración de subredes públicas (CIDR, AZ, Nombre)."
    type = map(object({
        cidr_block        = string
        availability_zone = string
        name              = string
    }))
}

variable "private_subnets" {
    description = "Configuración de subredes privadas (CIDR, AZ, Nombre)."
    type = map(object({
        cidr_block        = string
        availability_zone = string
        name              = string
    }))
}

variable "security_groups" {
    description = "Mapa de configuraciones para todos los Security Groups"
    type = map(object({
        name        = string
        description = optional(string)
    }))
}

variable "alb_configs" {
    description = "Mapa de configuraciones para cada Application Load Balancer (ALB)."
    type = map(object({
        lb_name             = string
        lb_internal         = bool
        subnet_keys         = list(string)
        security_group_keys = list(string)
        target_group_name   = string
        target_group_port   = number
        health_check_path   = optional(string)
        health_check_matcher = optional(string)
    }))
}
