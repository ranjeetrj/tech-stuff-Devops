provider "aws" {
  region = "us-east-2"
}
resource "aws_instance" "web" {
  ami           = "ami-0430580de6244e02e"
  instance_type = "t2.micro"
  key_name      = "pratibha"

  tags = {
    Name = "My-ubuntu-server"
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir /tmp/secure",
      "touch abcd",
      "rm -rvf /tmp/*"
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.public_ip
    }

  }
}
