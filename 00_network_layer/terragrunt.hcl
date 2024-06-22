include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-vpc.git?ref=v5.8.1"
}

inputs = {
  name = "test-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    application = "test-nginx-application"
    env = "dev"
    managed_by = "Terraform"
  }

  # Subnet_tags for AWS load balance controller autoDiscovery
  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }
}