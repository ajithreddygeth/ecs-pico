provider "aws" {
  version = ">= 2.28.1"
  region  = var.region
  profile = var.profile
}

provider "local" {
  version = "~> 1.2"
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc-name

  cidr = var.vpc-cidr

  azs                 = var.azs
  private_subnets     = var.private-subnets
  public_subnets      = var.public-subnets

  create_database_subnet_group = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_classiclink             = false
  enable_classiclink_dns_support = false

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_vpn_gateway = true

  enable_dhcp_options              = false
  dhcp_options_domain_name_servers = ["AmazonProvidedDNS"]

  # VPC endpoint for S3
  enable_s3_endpoint = true

  # VPC endpoint for DynamoDB
  enable_dynamodb_endpoint = true

  # VPC endpoint for SSM
  enable_ssm_endpoint              = false
  ssm_endpoint_private_dns_enabled = true
  ssm_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC Endpoint for EC2
  enable_ec2_endpoint              = false
  ec2_endpoint_private_dns_enabled = true
  ec2_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC Endpoint for ECR API
  enable_ecr_api_endpoint              = false
  ecr_api_endpoint_private_dns_enabled = true
  ecr_api_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC Endpoint for ECR DKR
  enable_ecr_dkr_endpoint              = false
  ecr_dkr_endpoint_private_dns_enabled = true
  ecr_dkr_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # VPC endpoint for KMS
  enable_kms_endpoint              = false
  kms_endpoint_private_dns_enabled = true
  kms_endpoint_security_group_ids  = [data.aws_security_group.default.id]

  # Default security group - ingress/egress rules cleared to deny all
  manage_default_security_group  = true
  default_security_group_ingress = [{}]
  default_security_group_egress  = [{}]


  tags = {
	Environment        = var.sdlc_env
    	BILLING            = "RD"
}

# public_subnet_tags = {
# 	"kubernetes.io/cluster/indigo2-dev-eks" = "shared"
# 	"kubernetes.io/role/elb" = 1
# }

# private_subnet_tags = {
#         "kubernetes.io/cluster/indigo2-dev-eks" = "shared"
#         "kubernetes.io/role/internal-elb" = 1
# }

}