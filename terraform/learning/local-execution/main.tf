provider "aws" {}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform Start: $(date) > logs.txt "
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 google.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command = "echo $NAME1 $NAME2 > names.txt"
    environment = {
      NAME1 = "RJ"
      NAME2 = "RAJ"
    }
  }
}
