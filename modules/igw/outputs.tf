output "internet_gateway_id" {
    description = "ID del IGW de la VPC"
    value       = aws_internet_gateway_attachment.this.id
}