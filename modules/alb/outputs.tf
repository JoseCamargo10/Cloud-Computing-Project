output "lb_arn" {
    description = "El ARN completo del Application Load Balancer creado"
    value       = aws_lb.this.arn
}

output "lb_dns_name" {
    description = "El nombre DNS para acceder al Load Balancer"
    value       = aws_lb.this.dns_name
}

output "lb_zone_id" {
    description = "El ID de la Zona Alojada de AWS para el DNS del Load Balancer."
    value       = aws_lb.this.zone_id
}

output "target_group_arn" {
    description = "El ARN del Target Group creado. Se utiliza para enlazar Listeners y Auto Scaling Groups (ASG)."
    value       = aws_lb_target_group.this.arn
}

output "target_group_arn_suffix" {
    description = "El sufijo ARN del Target Group (útil para ciertas políticas de IAM)."
    value       = aws_lb_target_group.this.arn_suffix
}

output "target_group_name" {
    description = "El nombre del Target Group creado."
    value       = aws_lb_target_group.this.name
}