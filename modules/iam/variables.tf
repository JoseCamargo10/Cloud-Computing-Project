variable "role_name" {
    description = "Nombre único para el rol de IAM de EC2."
    type        = string
}

variable "instance_profile_name" {
    description = "Nombre único para el perfil de instancia de IAM. (Solo necesario si el rol es para EC2)"
    type        = string
    default     = ""
}

variable "assume_role_policy_json" {
    description = "El documento JSON para la política de asunción de rol (Trust Policy)."
    type        = string
}

variable "attached_policies" {
    description = "Lista de ARNs de políticas administradas por AWS para adjuntar al rol."
    type        = list(string)
    default     = []
}