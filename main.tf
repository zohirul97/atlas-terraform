#Create S3 Bucket# #Created this resource first for Backend#
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name # Update with a globally unique bucket name
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}

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