terraform {
  backend "s3" {
    key            = "terraform-formations/dev/pico/us-west-2/vpc"
    bucket         = "terraform-backend-ds"
    dynamodb_table = "terraform-backend-ds"
    region         = "us-west-2"
    profile        = "pico"
  }
}