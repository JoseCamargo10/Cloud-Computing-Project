output "route_table_id" {
    description = "ID de la tabla de rutas creada."
    value       = aws_route_table.this.id
}