terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  profile = "tfuser"
}

# Configure the Kubernetes Provider
provider "kubernetes" {
  # Specify the Kubernetes API server address
  host = "https://06593D3CE2666BF4A6FBD08C9D5740F6.gr7.us-east-1.eks.amazonaws.com"
  insecure = true
}