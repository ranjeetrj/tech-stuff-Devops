
data "aws_region" "current" {}

data "aws_availability_zones" "working" {
  state = "available"
}

## create the vpc ########
resource "aws_vpc" "prod" {
  cidr_block       = var.main_vpc_cidr
  instance_tenancy = "default"
  tags = {
    Name = "prod-vpc"
  }
}

## create the IGW ########
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.prod.id
  tags = {
    Name = "prod-igw"
  }
}

## create the Public subnet ########
resource "aws_subnet" "public" {

  vpc_id                  = aws_vpc.prod.id
  cidr_block              = var.public_subnets
  availability_zone       = data.aws_availability_zones.working.names[0]
  map_public_ip_on_launch = "true"

  tags = {
    Name = "pub-subnet"
  }
}

## create the Private subnet ########
resource "aws_subnet" "private" {

  vpc_id            = aws_vpc.prod.id
  cidr_block        = var.private_subnets
  availability_zone = data.aws_availability_zones.working.names[1]

  tags = {
    Name = "pri-subnet"
  }
}

## create the route table for public subnet########
resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.prod.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "pub-rt"
  }
}

## create the route table for private subnet########
resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.prod.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = "pri-rt"
  }
}


## Route table association with public subnet########
resource "aws_route_table_association" "pub-rt-asso" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public-rt.id

}

## Route table association with private subnet########
resource "aws_route_table_association" "pri-rt-asso" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private-rt.id

}

## create the EIP for NAT ########
resource "aws_eip" "natip" {
  vpc = true
  tags = {
    Name = "nat-ip"
  }
}

## create the NAT GATEWAY ######
resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.natip.id
  tags = {
    Name = "nat-gw"
  }
}


## create the SG for webserver ########
resource "aws_security_group" "web-server" {
  name       = "My SG"
  vpc_id     = aws_vpc.prod.id
  depends_on = [aws_vpc.prod]
  dynamic "ingress" {
    for_each = ["80", "443", "22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "My Server Dynamic SG"
    Owner = "Ranjeet Jadhav"
  }

}


## create the AWS INSTANCE  ########
resource "aws_instance" "nginx" {
  ami                    = var.ami
  instance_type          = var.instance_size
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.web-server.id]
  subnet_id              = aws_subnet.public.id
  user_data              = file("user_data.sh")

  root_block_device {
    encrypted   = "true"
    volume_size = 10
  }

}

output "avaibility_zone" {
  value = data.aws_availability_zones.working.names
}

output "region" {
  value = data.aws_region.current.name
}

output "server_public_ip" {
  value = aws_instance.nginx.public_ip
}
