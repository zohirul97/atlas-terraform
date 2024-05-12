resource "aws_s3_bucket" "terraform_state" {
  bucket = "atlastech-state-bucket"  # Update with a globally unique bucket name
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.id

  versioning_configuration {
    status = "Enabled"
  }
}