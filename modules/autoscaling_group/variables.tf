variable "name_prefix" {
    description = "Prefijo para el nombre del Launch Template y el ASG"
    type        = string
}

variable "ami_id" {
    description = "ID de la AMI a usar para las instancias"
    type        = string
}

variable "instance_type" {
    description = "Tipo de instancia EC2 a lanzar (e.g., t2.micro, t3.medium)"
    type        = string
    default = "t2.micro"
}

variable "iam_instance_profile_arn" {
    description = "ARN del Instance Profile IAM para adjuntar a las instancias"
    type        = string
}

variable "security_group_ids" {
    description = "Lista de IDs de security groups para las instancias"
    type        = list(string)
}

variable "vpc_zone_identifier" {
    description = "Lista de IDs de subredes donde se lanzarán las instancias del ASG"
    type        = list(string)
}

variable "target_group_arns" {
    description = "Lista de ARNs de Target Groups donde el ASG registrará las instancias"
    type        = list(string)
    default     = []
}

variable "asg_min_size" {
    description = "Número mínimo de instancias en el ASG"
    type        = number
    default     = 1
}

variable "asg_max_size" {
    description = "Número máximo de instancias en el ASG"
    type        = number
    default     = 3
}

variable "asg_desired_capacity" {
    description = "Número deseado de instancias en el ASG al inicio"
    type        = number
    default     = 2
}

variable "associate_public_ip" {
    description = "Booleano para decidir si asociar IP pública a las instancias"
    type        = bool
    default     = false
}