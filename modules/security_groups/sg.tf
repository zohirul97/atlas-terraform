// Create a SG that will allow SSH, HTTP/s
resource "aws_security_group" "tf-sg1" {
  description = "Terraform Project SG"
  name        = "tf-sg1"
  vpc_id      = var.vpc_id

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
    cidr_blocks  = ["0.0.0.0/0"]
    description = "ALL Outbound Rule"
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 represents all IP protocols, including TCP, UDP, and ICMP
  }

}