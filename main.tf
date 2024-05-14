#Create S3 Bucket# #Created this resource first for Backend#
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = var.bucket_name # Update with a globally unique bucket name
# }

# resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
#   bucket = aws_s3_bucket.terraform_state.id

#   versioning_configuration {
#     status = "Enabled"
#   }
# }

#Create VPC#
// Create a VPC with CIDR Block, enable DNS hostname/support
resource "aws_vpc" "tf-vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = var.vpc_name
  }
}

// Create an Internet Gateway and associate it to your VPC
resource "aws_internet_gateway" "tf-ig1" {
  vpc_id = aws_vpc.tf-vpc1.id

  tags = {
    "Name" = var.ig_name
  }
}

// Create a Route Table, associate it to your VPC, create a default route
resource "aws_route_table" "tf-rt1" {
  vpc_id = aws_vpc.tf-vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig1.id
  }

  tags = {
    "Name" = var.rt_name
  }
}

// Create a subnet, associate it to your VPC, give it a CIDR block, choose an Availability Zone
resource "aws_subnet" "tf-subnet1" {
  vpc_id            = aws_vpc.tf-vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = var.subnet1_name
  }
}

// Associate the subnet with a Route Table
resource "aws_route_table_association" "subnetassociation" {
  subnet_id      = aws_subnet.tf-subnet1.id
  route_table_id = aws_route_table.tf-rt1.id
}

// Create a second subnet, associate it with your VPC, give it a CIDR block, and choose a different Availability Zone
resource "aws_subnet" "tf-subnet2" {
  vpc_id            = aws_vpc.tf-vpc1.id
  cidr_block        = "10.0.2.0/24" // Adjust the CIDR block as needed
  availability_zone = "us-east-1b"  // Choose a different AZ

  tags = {
    "Name" = var.subnet2_name
  }
}

// Associate the second subnet with the same Route Table
resource "aws_route_table_association" "subnetassociation2" {
  subnet_id      = aws_subnet.tf-subnet2.id
  route_table_id = aws_route_table.tf-rt1.id
}


#Security Group#
// Create a SG that will allow SSH, HTTP/s
resource "aws_security_group" "tf-sg1" {
  description = "Terraform Project SG"
  name        = var.sg_name
  vpc_id      = aws_vpc.tf-vpc1.id

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow SSH 22/tcp"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP 80/tcp"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
  }

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPs 443/tcp"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
  }

  egress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "ALL Outbound Rule"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 represents all IP protocols, including TCP, UDP, and ICMP
  }

}

#EKS-Role#
resource "aws_iam_role" "atlas_eks_role" {
  name = "atlas-eks-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "eks.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "example_attachment" {
  role       = aws_iam_role.atlas_eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


#EKS#
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.8.5"

  cluster_name    = var.cluster_name
  cluster_version = "1.29"

  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    aws-ebs-csi-driver = {
      service_account_role_arn = aws_iam_role.atlas_eks_role.arn
    }
  }

  vpc_id = aws_vpc.tf-vpc1.id
  subnet_ids = [
    aws_subnet.tf-subnet1.id,
    aws_subnet.tf-subnet2.id # Add subnet from another AZ
  ]

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64"

  }

  eks_managed_node_groups = {
    one = {
      name = "atlas-nodegroup-1"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 3
      desired_size = 2
    }

    two = {
      name = "atlas-nodegroup-2"

      instance_types = ["t2.micro"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }
}