terraform {
  backend "s3" {
    key            = "terraform-formations/dev/pico/us-west-2/ecs-service"
    bucket         = "terraform-backend-ds"
    dynamodb_table = "terraform-backend-ds"
    region         = "us-west-2"
    profile        = "pico"
  }
}