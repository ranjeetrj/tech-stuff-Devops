output "web_server_public_ip" {
  value = aws_instance.nginx.public_ip
}
