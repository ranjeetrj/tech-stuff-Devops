#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give Internet access from Private Subnets
#
# Developed by RANJEET JADHAV
#----------------------------------------------------------
provider "aws" {
  region = "us-east-2"

}

data "aws_availability_zones" "available" {}

#-------------VPC and Internet Gateway------------------------------------------
resource "aws_vpc" "sbi" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}


resource "aws_internet_gateway" "sbi" {
  vpc_id = aws_vpc.sbi.id
  tags   = merge(var.tags, { Name = "${var.env}-igw" })
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.sbi.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-public-${count.index + 1}" })
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.sbi.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sbi.id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-public-subnets" })
}


resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}


#-----NAT Gateways with Elastic IPs--------------------------
resource "aws_eip" "nat" {
  # count = length(var.private_subnet_cidrs)
  vpc  = true
  tags = merge(var.tags, { Name = "${var.env}-nat-gw" })
}


resource "aws_nat_gateway" "nat" {
  # count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags          = merge(var.tags, { Name = "${var.env}-nat-gw" })
}

#--------------Private Subnets and Routing-------------------------
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.sbi.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.tags, { Name = "${var.env}-private-${count.index + 1}" })
}


resource "aws_route_table" "private_subnets" {
  # count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.sbi.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-private-subnet" })
}


resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

#==============================================================

## create the SG for webserver ########
resource "aws_security_group" "web-server" {
  name       = "My SG"
  vpc_id     = aws_vpc.sbi.id
  depends_on = [aws_vpc.sbi]
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
  subnet_id              = aws_subnet.public_subnets[0].id
  user_data              = file("user_data.sh")

  root_block_device {
    encrypted   = "true"
    volume_size = 10
  }

}
