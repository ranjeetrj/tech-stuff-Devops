provider "aws" {
  region = "us-east-2"
}

import {
  id = "i-0608ce3759f38b3de"
  to = aws_instance.web
}

import {
  id = "sg-02bb5a61f09819222"
  to = aws_security_group.sg
}
