instance_size = "t2.micro"
ami           = "ami-024e6efaf93d85776"
key_name      = "sbi-web-server"
tags = {
  Name        = "nginx"
  server      = "web"
  Environment = "Prod"

}
ports = ["80", "443", "8088"]

