output "vpc_id" {
  value = aws_vpc.sbi.id
}

output "vpc_cidr" {
  value = aws_vpc.sbi.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}


output "server_public_ip" {
  value = aws_instance.nginx.public_ip
}
