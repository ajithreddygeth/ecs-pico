provider "aws" {
  version = ">= 2.28.1"
  region  = "us-east-1"
  profile = "pico"
}

module "ec2_cluster" {
  source                 = "terraform-aws-modules/ec2-instance/aws"
  version                = "~> 2.0"

  name                   = "pico-test"
  instance_count         = 1

  ami                    = "ami-03eaf3b9c3367e75c"
  instance_type          = "t2.micro"
  key_name               = "pico-setup"
  monitoring             = true
  vpc_security_group_ids = ["sg-04730f6ab265b9a1e"]
  subnet_id              = "subnet-057f6534ac2a24e12"

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}