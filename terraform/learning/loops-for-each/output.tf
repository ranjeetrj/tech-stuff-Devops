output "instace_id" {
  value = aws_instance.nginx[*].id
}

output "instance_public_ip" {
  value = aws_instance.nginx[*].public_ip

}

output "instance_id_ip" {
  value = {
    for instance in aws_instance.nginx :
    instance.id => instance.public_ip
  }
}
