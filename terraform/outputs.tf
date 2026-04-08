# ============================================================
# outputs.tf — Values printed after terraform apply
# ============================================================
# These outputs are also used by the GitHub Actions pipeline
# to know WHERE to deploy (the server's public IP).
# ============================================================

output "instance_public_ip" {
  description = "Public IP of the EC2 server"
  value       = aws_instance.devops_server.public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.devops_server.id
}

output "ssh_command" {
  description = "SSH into your server with this command"
  value       = "ssh -i your-key.pem ubuntu@${aws_instance.devops_server.public_ip}"
}

output "app_url" {
  description = "Access your app at this URL after deployment"
  value       = "http://${aws_instance.devops_server.public_ip}:30080"
}
