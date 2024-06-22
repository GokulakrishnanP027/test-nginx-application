# Test nginx application

## Overview

This repository contains Terraform configurations managed with Terragrunt to set up a robust infrastructure on AWS. It utilizes the following modules:

1. **VPC Module**: Creates the networking infrastructure.
2. **EKS Module**: Deploys an Elastic Kubernetes Service (EKS) cluster.
3. **Custom NGINX Module**: Deploys an NGINX application on the EKS cluster.

## Architecture

1. **VPC**: We use the `terraform-aws-modules/vpc/aws` module to create a Virtual Private Cloud (VPC) with the necessary subnets, route tables, internet and NAT gateways.
2. **EKS**: The `terraform-aws-modules/eks/aws` module is used to deploy an EKS cluster on top of the created VPC.
3. **NGINX**: A custom module is used to deploy an NGINX application within the EKS cluster.

## Prerequisites

- Terraform v1.0.0+
- Terragrunt v0.35.0+
- Helm 3.15.0+
- AWS CLI configured with appropriate permissions
- kubectl configured for EKS

## Directory Structure

The directory structure is organized as follows:

```
.
├── 00_network
│   └── terragrunt.hcl
├── 01_eks
│   └── terragrunt.hcl
├── 02_nginx-application
│   └── terragrunt.hcl
└── terragrunt.hcl
```

## Usage

### Step 1: Clone the Repository

```bash
git clone git@github.com:GokulakrishnanP027/test-nginx-application.git
cd test-nginx-application
```

### Step 2: Initialize Terragrunt

Initialize the Terragrunt configuration to download the necessary modules.

Please change the appropriate values in root terragrunt file.

```bash
locals {
  account_name = "*****************"
  account_id   = "*****************"
  aws_region   = "eu-west-1"
}
```

```bash
terragrunt run-all init
```

### Step 3: Review and Modify Variables

Review the variables defined in the `terragrunt.hcl` files located in each directory (`00_network/terragrunt.hcl`, `01_eks/terragrunt.hcl`, `nginx-application/terragrunt.hcl`) and modify them as per your requirements.

### Step 4: Plan the Terraform Configuration

Run the following command to plan the Terraform configuration.

```bash
terragrunt run-all plan
```

### Step 5: Apply the Terraform Configuration

Apply the Terraform configuration to create the VPC, EKS cluster, and deploy the NGINX application.

```bash
terragrunt run-all apply
```

### Step 6: Configure kubectl

Once the EKS cluster is created, configure `kubectl` to interact with your cluster.

```bash
aws eks --region eu-west-1 update-kubeconfig --name test-cluster
```

### Step 7: Verify Deployment

Verify that the NGINX application is running on your EKS cluster.

```bash
kubectl get pods -n default
```

#### Step 8: Get NGINX Ingress Hostname

Run the following command to retrieve the hostname of the NGINX Ingress:

```bash
NGINX_DNS=$(kubectl get ingress nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
```

This command extracts the hostname from the NGINX Ingress resource.

#### Step 9: Check NGINX Status

After obtaining the NGINX Ingress hostname, use `curl` to check the status of NGINX:

```bash
curl -I $NGINX_DNS
```
You should see a response indicating the status of NGINX, such as `HTTP/1.1 200 OK` for a successful response.

- **00_network**: Contains the configuration for the VPC module.
- **01_eks**: Contains the configuration for the EKS module.
- **nginx-application**: Contains the configuration for deploying the NGINX application.

## Outputs

The following outputs are provided by the modules:

- **VPC Module**: VPC ID, subnet IDs, route table IDs.
- **EKS Module**: Cluster name, cluster endpoint, kubeconfig.
- **NGINX Module**: Service endpoint, deployment status.

## Clean Up

To destroy the created infrastructure, run:

```bash
terragrunt run-all destroy
```

## Contributing

We welcome contributions. Please see `CONTRIBUTING.md` for details.

## License

This project is licensed under the MIT License - see the `LICENSE` file for details.

## Authors

- Your Name - [GokulakrishnanP027](https://github.com/GokulakrishnanP027)

---

Feel free to reach out if you have any questions or need further assistance. Happy deploying!