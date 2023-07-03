

data "aws_availability_zones" "working" {}
data "aws_subnet" "web" {
  id = var.subnet_id
}

resource "aws_instance" "nginx" {
  ami           = var.ami
  instance_type = var.instance_size
  key_name      = var.key_pair
  subnet_id     = var.subnet_id
  user_data     = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<HTMLTEXT > /var/www/html/index.html
<h2>
${var.name} WebServer with IP: $myip <br>
${var.name} WebServer in AZ: ${data.aws_subnet.web.availability_zone}<br>
Message:</h2> ${var.message}
HTMLTEXT

service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "${var.name}-WebServer-${var.subnet_id}"
    Owner = "RANJEET JADHAV"
  }
}


resource "aws_security_group" "webserver" {
  name_prefix = "${var.name} WebServer SG-"
  vpc_id      = data.aws_subnet.web.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.name}-web-server-sg"
    Owner = "RANJEET JADHAV"
  }
}



