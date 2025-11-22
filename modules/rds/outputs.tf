output "db_cluster_endpoint" {
  description = "Endpoint de escritor (writer) del cluster Aurora."
  value       = aws_rds_cluster.aurora_cluster.endpoint
}

output "db_cluster_reader_endpoint" {
  description = "Endpoint de solo lectura (reader) del cluster Aurora."
  value       = aws_rds_cluster.aurora_cluster.reader_endpoint
}