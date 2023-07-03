provider "aws" {
  region = "us-east-2"
}

module "my_default_vpc" {
  source = "../module/aws_network"
}


module "my_vpc_staging" {
  source               = "../module/aws_network"
  env                  = "staging"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24"]
  private_subnet_cidrs = []
}
