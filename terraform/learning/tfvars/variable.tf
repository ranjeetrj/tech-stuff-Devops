variable "instance_size" {
  description = "This is an size of instance"
  type        = string
}

variable "ami" {
  description = "Ami which is used by instance"
  type        = string
}

variable "key_name" {
  description = "Key used by instance"
  type        = string
}

variable "tags" {
  description = "tag for the instances"
  type        = map(any)
}

variable "ports" {
  description = "List of ports to open in SG"
  type        = list(any)

}

