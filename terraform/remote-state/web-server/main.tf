##### To store terraform.tfstate to remove location on aws s3 bucket ###########

terraform {
  backend "s3" {
    bucket = "helm-remote-state"
    key    = "dev/web/terraform.tfstate"
    region = "us-east-2"

  }
}


########## To fetch data from remote terraform.tfstate file ###############

data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = "helm-remote-state"
    key    = "dev/network/terraform.tfstate"
    region = "us-east-2"
  }

}


## create the SG for webserver ########

resource "aws_security_group" "web-server" {
  name   = "My SG"
  vpc_id = data.terraform_remote_state.vpc.outputs.vpc_id ### syntax to fetch data from remote terraform.tfstate file
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
  subnet_id              = data.terraform_remote_state.vpc.outputs.subnet_id ### syntax to fetch data from remote terraform.tfstate file
  user_data              = file("user_data.sh")

  root_block_device {
    encrypted   = "true"
    volume_size = 10
  }

}


