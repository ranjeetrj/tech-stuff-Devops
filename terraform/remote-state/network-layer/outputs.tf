output "avaibility_zone" {
  value = data.aws_availability_zones.working.names
}

output "vpc_id" {
  value = aws_vpc.prod.id

}

output "main_cidr" {
  value = aws_vpc.prod.cidr_block
}

output "subnet_id" {
  value = aws_subnet.public.id

}
