provider "aws" {
  region = "us-east-2"
}

resource "aws_instance" "web" {
  for_each      = toset(["Dev", "Staging", "Prod"])
  ami           = "ami-024e6efaf93d85776"
  instance_type = "t2.small"
  tags = {
    Name  = "Server-${each.value}"
    Owner = "Ranjeet"
  }

}


resource "aws_instance" "servers" {
  for_each      = var.server_setting
  ami           = each.value["ami"]
  instance_type = each.value["instance_size"]

  root_block_device {
    volume_size = each.value["root_disk"]
    encrypted   = each.value["encrypted"]
  }
  volume_tags = {
    Name = "Disk-${each.key}"
  }
  tags = {
    Name   = "Server-${each.key}"
    Owener = "Ranjeet"
  }

}
