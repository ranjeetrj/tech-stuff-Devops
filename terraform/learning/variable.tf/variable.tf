variable "instance_size" {
  description = "This is an size of instance"
  type        = string
  default     = "t2.micro"
}

variable "ami" {
  description = "Ami which is used by instance"
  type        = string
  default     = "ami-024e6efaf93d85776"

}

variable "key_name" {
  description = "Key used by instance"
  type        = string
  default     = "sbi-web-server"
}

variable "tags" {
  description = "tag for the instances"
  type        = map(any)
  default = {
    Name   = "nginx"
    server = "web"
  }
}

variable "ports" {
  description = "List of ports to open in SG"
  type        = list(any)
  default     = ["80", "443", "8088"]

}

