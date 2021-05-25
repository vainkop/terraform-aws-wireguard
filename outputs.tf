output "eip_id" {
  value       = var.use_eip ? aws_eip.wireguard[0].id : null
  description = "The elastic IP id (if `use_eip` is enabled)"
}
