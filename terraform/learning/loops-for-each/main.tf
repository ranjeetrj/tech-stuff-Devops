provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "nginx" {
  count         = 4 #### to deploy 4 same identical instances we are using count
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.small"
  tags = {
    Name = "server ${count.index + 1}" ############ By default it will start from 0 so we have added + 1
  }
}





resource "aws_instance" "baston_server" {
  count         = var.create_bastion == "YES" ? 1 : 0 ### Conditon to deploy baston server or not,,value taken from varaible.tf
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.small"
  tags = {
    Name = "Baston server"
  }
}
