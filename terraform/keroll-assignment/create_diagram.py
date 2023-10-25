from diagrams import Diagram
from diagrams.aws.compute import EC2
from diagrams.aws.network import VPC, InternetGateway, Subnet
from diagrams.aws.database import RDS

with Diagram("Terraform Architecture", show=False):
    # Define VPC and Internet Gateway
    with VPC("MyVPC"):
        igw = InternetGateway("IGW")

        # Define public and private subnets
        with Subnet("Public"):
            public_subnet = EC2("Public Instance")

        with Subnet("Private"):
            private_subnet = EC2("Private Instance")
        
        # Connect VPC to Internet Gateway
        igw >> public_subnet

        # Define RDS Database
        rds = RDS("MyDatabase")

        # Connect Database to Private Subnet
        rds >> private_subnet

