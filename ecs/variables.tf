# main creds for AWS connection
variable "ecs_cluster" {
  description = "ECS cluster name"
}

variable "ecs_key_pair_name" {
  description = "ECS key pair name"
}



variable "region" {
  description = "AWS region"
}

variable "availability_zone" {
  description = "availability zone used for the demo, based on region"
  default = {
    us-east-1 = "us-east-1"
  }
}

########################### Test VPC Config ################################

variable "test_vpc" {
  description = "VPC for Test environment"
}

variable "vpc_id" {
  description = "VPC ID"
}
variable "pubsub1_id" {
    description = "subnetid"
  
}
variable "pubsub2_id" {
    description = "subnetid"
  
}

variable "pubsub1_cidr" {
    description = "subnetCIDR"
  
}
variable "pubsub2_cidr" {
    description = "subnetCIDR"
  
}

variable "prisub1_id" {
    description = "subnetid"
  
}
variable "prisub2_id" {
    description = "subnetid"
  
}

variable "prisub1_cidr" {
    description = "subnetCIDR"
  
}
variable "prisub2_cidr" {
    description = "subnetCIDR"
  
}

########################### Autoscale Config ################################

variable "max_instance_size" {
  description = "Maximum number of instances in the cluster"
}

variable "min_instance_size" {
  description = "Minimum number of instances in the cluster"
}

variable "desired_capacity" {
  description = "Desired number of instances in the cluster"
}
