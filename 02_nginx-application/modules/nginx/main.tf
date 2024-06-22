data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_iam_openid_connect_provider" "oidc_provider" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

resource "null_resource" "helm_repo_add" {
  provisioner "local-exec" {
    command = "helm repo add eks https://aws.github.io/eks-charts && helm repo add bitnami https://charts.bitnami.com/bitnami && helm repo update"
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
      command     = "aws"
    }
  }
}

# This is not recommond way fo deploying helm releases, i would rather use helmfile, since it is small project I have choose terragrunt
resource "helm_release" "alb_controller" {
  depends_on = [var.mod_dependency]
  count      = var.enabled ? 1 : 0
  name       = "aws-load-balancer-controller"
  chart      = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  version    = "1.8.1"
  namespace  = "kube-system"

  values = [
    templatefile("${path.module}/alb.yaml", {
      clusterName = var.cluster_name,
      serviceAccountName = var.service_account_name,
      alb_irsa = aws_iam_role.kubernetes_alb_controller[0].arn
    })
  ]
}

resource "helm_release" "nginx" {
  depends_on = [resource.helm_release.alb_controller]

  name       = "nginx"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "nginx"
  version    = "18.1.2"

  values = [
    file("${path.module}/nginx-values.yaml")
  ]
}

// Introduce a delay to wait for the ALB provisioning
resource "time_sleep" "wait_for_alb" {
  create_duration = "2m"
}

resource "null_resource" "get_alb_dns" {
  depends_on = [resource.time_sleep.wait_for_alb]

  provisioner "local-exec" {
    command = <<EOT
    kubectl get ingress nginx -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
    EOT

    environment = {
      AWS_DEFAULT_REGION = var.aws_region
    }
  }
}

// Output the DNS name of the ALB
output "alb_dns_name" {
  value = null_resource.get_alb_dns.*.triggers[0]
}