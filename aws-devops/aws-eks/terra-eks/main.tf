#----------------------------------------------------------
#  Terraform - From Zero to Certified Professional
#
# Provision:
#  - VPC
#  - Internet Gateway
#  - XX Public Subnets
#  - XX Private Subnets
#  - XX NAT Gateways in Public Subnets to give Internet access from Private Subnets
#
# Developed by RANJEET JADHAV
#----------------------------------------------------------
provider "aws" {
  region = "us-east-2"

}

data "aws_availability_zones" "available" {}

#-------------VPC and Internet Gateway------------------------------------------
resource "aws_vpc" "sbi" {
  cidr_block = var.vpc_cidr
  tags       = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_internet_gateway" "sbi" {
  vpc_id = aws_vpc.sbi.id
  tags   = merge(var.tags, { Name = "${var.env}-igw" })
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.sbi.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = merge(var.tags, { Name = "${var.env}-public-${count.index + 1}" })
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.sbi.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.sbi.id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-public-subnets" })
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnets[count.index].id
}

#-----NAT Gateways with Elastic IPs--------------------------

resource "aws_eip" "nat" {
  # count = length(var.private_subnet_cidrs)
  vpc  = true
  tags = merge(var.tags, { Name = "${var.env}-nat-gw" })
}


resource "aws_nat_gateway" "nat" {
  # count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags          = merge(var.tags, { Name = "${var.env}-nat-gw" })
}

#--------------Private Subnets and Routing-------------------------
resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.sbi.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags              = merge(var.tags, { Name = "${var.env}-private-${count.index + 1}" })
}

resource "aws_route_table" "private_subnets" {
  # count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.sbi.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = merge(var.tags, { Name = "${var.env}-route-private-subnet" })
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
}

# #==============================================================

# resource "aws_iam_role" "eks_cluster-terra" {
#   name               = "eks-cluster-terra"
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "eks.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
#   role       = aws_iam_role.eks_cluster-terra.name
# }


# resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
#   role       = aws_iam_role.eks_cluster-terra.name
# }

# resource "aws_eks_cluster" "aws_eks" {
#   name     = "eks-cluster-terra"
#   role_arn = aws_iam_role.eks_cluster-terra.arn

#   vpc_config {
#     subnet_ids              = ["${aws_subnet.private_subnets[0].id}", "${aws_subnet.private_subnets[1].id}", "${aws_subnet.public_subnets[0].id}", "${aws_subnet.public_subnets[1].id}"]
#     endpoint_private_access = true
#     endpoint_public_access  = true
#     public_access_cidrs     = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name  = "eks-terra"
#     Owner = "Ranjeet Jadhav"
#   }
# }

# resource "aws_iam_role" "eks-node-grp-terra" {
#   name               = "eks-nodegrp-terra"
#   assume_role_policy = <<POLICY
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Service": "ec2.amazonaws.com"
#       },
#       "Action": "sts:AssumeRole"
#     }
#   ]
# }
# POLICY  
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
#   role       = aws_iam_role.eks-node-grp-terra.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
#   role       = aws_iam_role.eks-node-grp-terra.name
# }

# resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
#   role       = aws_iam_role.eks-node-grp-terra.name
# }


# resource "aws_eks_node_group" "node" {
#   cluster_name    = aws_eks_cluster.aws_eks.name
#   node_group_name = "eks-node-group-terra"
#   node_role_arn   = aws_iam_role.eks-node-grp-terra.arn
#   instance_types  = ["t2.medium"]
#   subnet_ids      = ["${aws_subnet.private_subnets[0].id}", "${aws_subnet.private_subnets[1].id}"]
#   ami_type        = "AL2_x86_64" # AL2_x86_64, AL2_x86_64_GPU, AL2_ARM_64, CUSTOM
#   capacity_type   = "ON_DEMAND"  # ON_DEMAND, SPOT
#   disk_size       = 20

#   scaling_config {
#     desired_size = 1
#     max_size     = 1
#     min_size     = 1
#   }

#   # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
#   # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
#   depends_on = [
#     aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
#     aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
#     aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
#   ]
# }
