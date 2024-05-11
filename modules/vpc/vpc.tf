// Create a VPC with CIDR Block, enable DNS hostname/support
resource "aws_vpc" "tf-vpc1" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    "Name" = "tf-vpc1"
  }
}

// Create an Internet Gateway and associate it to your VPC
resource "aws_internet_gateway" "tf-ig1" {
  vpc_id = aws_vpc.tf-vpc1.id

  tags = {
    "Name" = "tf-ig1"
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
    "Name" = "tf-route1"
  }
}

// Create a subnet, associate it to your VPC, give it a CIDR block, choose an Availability Zone
resource "aws_subnet" "tf-subnet1" {
  vpc_id            = aws_vpc.tf-vpc1.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    "Name" = "tf-subnet1"
  }
}

// Associate the subnet with a Route Table
resource "aws_route_table_association" "subnetassociation" {
  subnet_id      = aws_subnet.tf-subnet1.id
  route_table_id = aws_route_table.tf-rt1.id
}