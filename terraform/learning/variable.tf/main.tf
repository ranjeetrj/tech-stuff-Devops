provider "aws" {
  region = "us-east-2"

}

resource "aws_default_vpc" "default" {}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  tags = {
    Name   = "nginx"
    server = "web"
  }
}

resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_size
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data              = file("user_data.sh")
  key_name               = var.key_name
  tags                   = var.tags
  lifecycle { ####### It will launch first new instance and then destory old instance
    create_before_destroy = true
  }
  depends_on = [aws_security_group.allow_tls] ## This resource will launch after security group will be created.
}

resource "aws_security_group" "allow_tls" {
  name   = "allow_tls"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id


  dynamic "ingress" {
    for_each = var.ports
    content {
      description = "TLS from VPC"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  }

  tags = {
    Name  = "WebServer SG by Terraform"
    Owner = "RANJEET"
  }
}

output "pub_ip" {
  value = "aws_instance.web.public_ip" ##### To print Instance public IP.
}



