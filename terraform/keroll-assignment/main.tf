# Developed by RANJEET JADHAV
#----------------------------------------------------------
data "aws_availability_zones" "available" {}

#-------------VPC and Internet Gateway------------------------------------------
resource "aws_vpc" "kerol" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_internet_gateway" "kerol" {
  vpc_id = aws_vpc.kerol.id
  tags   = merge(var.tags, { Name = "${var.env}-igw" })
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.kerol.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-public-${count.index + 1}" })
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.kerol.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kerol.id
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
  vpc_id            = aws_vpc.kerol.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.tags, { Name = "${var.env}-private-${count.index + 1}" })
}

resource "aws_route_table" "private_subnets" {
  # count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.kerol.id
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

#//

## create the AWS INSTANCE  ########
resource "aws_instance" "nginx" {
  count = 2

  ami                    = var.ami
  instance_type          = var.instance_size
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.private_instances.id]
  subnet_id              = element([for subnet in aws_subnet.private_subnets : subnet.id], count.index)
  user_data              = file("user_data.sh")

  root_block_device {
    encrypted   = "true"
    volume_size = 10
  }
  tags = {
    Name        = "Private-instance-${count.index + 1}"
    Environment = "Private"
  }
}


resource "aws_instance" "baston" {
  count = 1

  ami                    = var.ami
  instance_type          = var.instance_size
  key_name               = var.key_pair
  vpc_security_group_ids = [aws_security_group.baston.id]
  subnet_id              = element([for subnet in aws_subnet.public_subnets : subnet.id], count.index)
  # user_data              = file("user_data.sh")

  root_block_device {
    encrypted   = "true"
    volume_size = 10
  }
  tags = {
    Name        = "Baston-instance"
    Environment = "Public"
  }
}

#######################################################################################


# Create Network Load Balancer (NLB)
resource "aws_lb" "network" {
  name                       = "${var.env}-nlb"
  load_balancer_type         = "network"
  subnets                    = aws_subnet.public_subnets[*].id
  enable_deletion_protection = false
  security_groups            = [aws_security_group.nlb.id]


  tags = merge(var.tags, { Name = "${var.env}-nlb" })
}

resource "aws_security_group" "nlb" {
  name_prefix = "${var.env}-nlb-sg"
  vpc_id      = aws_vpc.kerol.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  }
}


# Create Security Groups for private instances
resource "aws_security_group" "private_instances" {
  name_prefix = "${var.env}-private-instances-sg"
  vpc_id      = aws_vpc.kerol.id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.nlb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group_rule" "ssh_from_baston" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["${aws_instance.baston[0].private_ip}/32"]
  security_group_id = aws_security_group.private_instances.id
}

resource "aws_security_group" "baston" {
  name_prefix = "${var.env}-baston-sg"
  vpc_id      = aws_vpc.kerol.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["152.58.31.195/32"]
  }
  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [for subnet in aws_subnet.private_subnets : subnet.cidr_block]
  }
}

resource "aws_lb_target_group" "network" {
  name     = "${var.env}-nlb-target-group"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.kerol.id

  health_check {
    port = 80
  }
}


resource "aws_lb_listener" "network" {
  load_balancer_arn = aws_lb.network.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.network.arn
  }
}

resource "aws_lb_target_group_attachment" "private_instances" {
  count            = 2
  target_group_arn = aws_lb_target_group.network.arn
  target_id        = aws_instance.nginx[count.index].id
}

