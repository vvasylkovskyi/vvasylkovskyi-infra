output "database_host" {
  description = "The hostname of the RDS instance"
  value       = aws_db_instance.database.address
}

output "database_port" {
  description = "The port of the RDS instance"
  value       = aws_db_instance.database.port
}