include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://github.com/terraform-aws-modules/terraform-aws-eks?ref=v20.14.0"
}

dependency "network" {
  config_path = "../00_network_layer"
}

inputs = {
  cluster_name    = "test-cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access  = true

  cluster_addons = {
    coredns                = "v1.11.1-eksbuild.9"
    kube-proxy             = "v1.30.0-eksbuild.3"
    vpc-cni                = "v1.18.2-eksbuild.1"
  }

  vpc_id                   = dependency.network.outputs.vpc_id
  subnet_ids               = dependency.network.outputs.private_subnets

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t3.small"]

    ami_type       = "AL2023_x86_64_STANDARD"

    min_size     = 1
      max_size     = 1
      desired_size = 1
  }

  eks_managed_node_groups = {
    az-1 = {
      # Creating nodes in different availablity zones
      subnet_ids = [dependency.network.outputs.private_subnets[0]]
    }
    az-2 = {
      # Creating nodes in different availablity zones
      subnet_ids = [dependency.network.outputs.private_subnets[1]]
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  enable_cluster_creator_admin_permissions = true

  # Access entries can be extended if any additional users needs to be access.
  access_entries = {}

  tags = {
    application = "test-nginx-application"
    env = "dev"
    managed_by = "Terraform"
  }
}