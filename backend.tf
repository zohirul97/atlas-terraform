terraform {
  backend "s3" {
    profile = "tfuser"
    bucket  = "atlastech-state-bucket"
    key     = "terraform.tfstate"
    region  = "us-east-1"
    #    dynamodb_table = "zohirul-test-state"
  }
}