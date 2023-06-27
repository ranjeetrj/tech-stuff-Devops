provider "aws" {}

data "aws_region" "current" {}             ######### To fetch current aws region
data "aws_caller_identity" "current" {}    ######### To fetch current aws account id
data "aws_availability_zones" "working" {} ######### To fetch current region avaibility zones
data "aws_vpcs" "vpcs" {}

data "aws_vpc" "prod" {
  tags = {
    Name = "PROD"
  }
}

resource "aws_subnet" "public" {
  vpc_id = data.aws_vpc.prod.id

  availability_zone = data.aws_availability_zones.working.names[0]
  cidr_block        = "10.0.1.0/24"

  tags = {
    Name = "sub-1"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = data.aws_vpc.prod.id
  availability_zone = data.aws_availability_zones.working.names[1]
  cidr_block        = "10.0.2.0/24"

  tags = {
    Name = "sub-2"
  }
}



output "region_name" {
  value = data.aws_region.current.name ######### To print current aws region
}

output "region_description" {
  value = data.aws_region.current.description
}

output "caller_name" {
  value = data.aws_caller_identity.current.account_id ######### To print current aws account id
}

output "avaibility_zones" {
  value = data.aws_availability_zones.working.names
}

output "vpcs" {
  value = data.aws_vpcs.vpcs.ids

}
