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


module "web-server" {
  source        = "../module/aws_testserver"
  ami           = "ami-02b8534ff4b424939"
  key_pair      = "sbi-web-server"
  instance_size = "t2.micro"
  subnet_id     = module.my_vpc_staging.public_subnet_ids[0]

}
