provider "aws" {
  region = "us-west-2"
}

data "aws_region" "current" {}

resource "aws_default_vpc" "default" {}

resource "aws_instance" "nginx" {
  ami                    = var.ami_id_per_region[data.aws_region.current.name]             ### it will take ami id based on specific region
  instance_type          = lookup(var.server_size, var.env, var.server_size["my_default"]) ### it will take server size based on env like dev prod
  vpc_security_group_ids = [aws_security_group.nginx.id]

  root_block_device {
    volume_size = 10
    encrypted   = var.env == "prod" ? true : false ## if env is prod then only encrypt otherwise dont encrypt
  }

  ###### If env is prod then only create secondary volume, for that we are creating the dynamic block:
  dynamic "ebs_block_device" {
    for_each = var.env == "prod" ? [true] : []
    content {
      device_name = "/dev/sdb"
      volume_size = 40
      encrypted   = true
    }
  }

  volume_tags = { Name = "Disk-${var.env}" }
  tags        = { Name = "Server-${var.env}" }
}

resource "aws_security_group" "nginx" {
  name   = "my-security-group"
  vpc_id = aws_default_vpc.default.id

  dynamic "ingress" {
    for_each = lookup(var.allow_port, var.env, var.allow_port["rest"])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = {
    Name  = "My dynamic web server"
    Owner = "My nginx web-server"
  }
}
