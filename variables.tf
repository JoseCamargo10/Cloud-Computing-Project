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

variable "ingress_rules" {
    description = "Mapa de configuraciones para todas las reglas de Security Group Ingress."
    type = map(object({
        # SG que recibe el tráfico (e.g., web_tier_sg)
        target_sg_key     = string 
        
        # Origen del tráfico (puede ser CIDR o clave de SG)
        source_type       = string 
        source_key_or_cidr = string 
        
        ip_protocol       = string
        to_port           = number
    }))
}











variable "vpc_cidr" {
    description = "CIDR de la VPC"
    type = string
}

variable "vpc_name" {
    description = "Nombre de la VPC"
    type = string
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
        lb_internal         = bool              # Define si usa subredes públicas (false) o privadas (true)
        subnet_keys         = list(string)      # Claves de las subredes (ej: "web_az1")
        security_group_keys = list(string)      # Claves de los Security Groups (ej: "web_sg")
        target_group_name   = string
        target_group_port   = number
        health_check_path   = optional(string)
        health_check_matcher = optional(string)
    }))
}
