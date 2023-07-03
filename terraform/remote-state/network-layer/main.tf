data "aws_availability_zones" "working" {
  state = "available"
}

### Below block is used to store the terrform.tfstate file on remote location that is S3 bucket
terraform {
  backend "s3" {
    bucket = "helm-remote-state"             ############# bucket name
    key    = "dev/network/terraform.tfstate" ########## path to store file
    region = "us-east-2"

  }
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



