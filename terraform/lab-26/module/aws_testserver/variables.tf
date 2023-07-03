variable "ami" {}
variable "key_pair" {}
variable "instance_size" {}
variable "subnet_id" {}
variable "name" {
  default = "Dev"
}

variable "message" {
  default = "HelloWorld"
}

