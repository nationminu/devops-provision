output "server_ids" {
  description = "List of IDs of was instances"
  value       = aws_instance.server.*.id
}