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
  ami                    = "ami-024e6efaf93d85776"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_tls.id]
  user_data              = <<EOF
#!/bin/bash
apt-get update --fix-missing
apt-get install nginx -y 
echo "<h2>WebServer with PrivateIP: RANJEET</h2><br>Built by Terraform" > /var/www/html/index.html
service nginx start
systemctl enable nginx
EOF
  key_name               = "sbi-web-server"
  tags = {
    Name   = "nginx"
    server = "web"
  }
  lifecycle { ####### It will launch first new instance and then destory old instance
    create_before_destroy = true
  }
  depends_on = [aws_security_group.allow_tls] ## This resource will launch after security group will be created.
}

resource "aws_security_group" "allow_tls" {
  name   = "allow_tls"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id


  dynamic "ingress" {
    for_each = ["80", "443", "22"]
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
