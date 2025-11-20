output "security_group_id" {
    description = "El ID del Security Group creado."
    value       = aws_security_group.this.id
}

output "security_group_arn" {
    description = "El ARN del Security Group creado."
    value       = aws_security_group.this.arn
}