variable "server_setting" {
  type = map(any)
  default = {
    web = {
      ami           = "ami-024e6efaf93d85776"
      instance_size = "t2.small"
      root_disk     = 20
      encrypted     = true
    }
    app = {
      ami           = "ami-024e6efaf93d85776"
      instance_size = "t2.small"
      root_disk     = 20
      encrypted     = false
    }
  }

}
