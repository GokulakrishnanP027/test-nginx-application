include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "./modules/nginx"
}

dependency "eks" {
  config_path = "../01_eks"
}

inputs = {
  cluster_name                     = dependency.eks.outputs.cluster_name
  aws_region                       = "eu-west-1"
}