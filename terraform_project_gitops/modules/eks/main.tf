################################################
# EKS Cluster + Node Group + IAM + IRSA + Helm
############################################

provider "aws" {
  region = var.aws_region
}

##### EKS Cluster IAM Role (minimal required attachments) #####
data "aws_iam_policy_document" "cluster_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cluster_role" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role_policy_attachment" "cluster_VPCResourceController" {
  role       = aws_iam_role.cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}

##### EKS Cluster #####
resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster_role.arn

  vpc_config {
    subnet_ids = var.private_subnet_ids
    endpoint_public_access = var.endpoint_public_access
    endpoint_private_access = var.endpoint_private_access
  }

  tags = merge(var.tags, { "Name" = var.cluster_name })
  depends_on = [aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy]
}

##### OIDC provider (required for IRSA) #####
resource "aws_iam_openid_connect_provider" "eks" {
  count = var.create_oidc_provider ? 1 : 0

  client_id_list  = ["sts.amazonaws.com"]
  url             = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "https://")
  thumbprint_list = [var.oidc_thumbprint]
}

##### Node group IAM Role #####
data "aws_iam_policy_document" "node_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "node_role" {
  name               = "${var.cluster_name}-node-role"
  assume_role_policy = data.aws_iam_policy_document.node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  role       = aws_iam.role != null ? aws_iam_role.node_role.name : aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_CNI" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_RegistryReadOnly" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

##### Managed Node Group #####
resource "aws_eks_node_group" "managed" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-managed-ng"
  node_role_arn   = aws_iam_role.node_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = var.instance_types
  capacity_type  = var.capacity_type

  tags = merge(var.tags, { "Name" = "${var.cluster_name}-managed-ng" })
  depends_on = [aws_eks_cluster.this]
}

##########################################
# IRSA roles for Cluster Autoscaler, ALB Controller, EBS CSI driver
##########################################

# helper: cluster issuer without https prefix
locals {
  oidc_provider_url = replace(aws_eks_cluster.this.identity[0].oidc[0].issuer, "https://", "")
}

# Cluster Autoscaler IRSA
data "aws_iam_policy_document" "autoscaler_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:cluster-autoscaler"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "irsa_cluster_autoscaler" {
  count               = var.create_irsa ? 1 : 0
  name                = "${var.cluster_name}-irsa-cluster-autoscaler"
  assume_role_policy  = data.aws_iam_policy_document.autoscaler_assume.json
  tags                = var.tags
}

resource "aws_iam_role_policy" "cluster_autoscaler_policy" {
  count = var.create_irsa ? 1 : 0
  name  = "${var.cluster_name}-cluster-autoscaler-policy"
  role  = aws_iam_role.irsa_cluster_autoscaler[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup",
          "ec2:DescribeLaunchTemplateVersions"
        ]
        Resource = "*"
      }
    ]
  })
}

# ALB Controller IRSA
data "aws_iam_policy_document" "alb_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "irsa_alb" {
  count              = var.create_irsa ? 1 : 0
  name               = "${var.cluster_name}-irsa-alb"
  assume_role_policy = data.aws_iam_policy_document.alb_assume.json
  tags               = var.tags
}

# Attach pre-bundled policy for ALB (user should provide policy JSON path to upload)
resource "aws_iam_policy" "alb_controller_policy" {
  count  = var.create_irsa && fileexists("${path.module}/policies/aws-load-balancer-controller.json") ? 1 : 0
  name   = "${var.cluster_name}-alb-controller-policy"
  policy = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "alb_attach" {
  count      = length(aws_iam_policy.alb_controller_policy) > 0 ? 1 : 0
  role       = aws_iam_role.irsa_alb[0].name
  policy_arn = aws_iam_policy.alb_controller_policy[0].arn
}

# EBS CSI IRSA (example minimal)
data "aws_iam_policy_document" "ebs_assume" {
  statement {
    effect = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks[0].arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
  }
}

resource "aws_iam_role" "irsa_ebs" {
  count              = var.create_irsa ? 1 : 0
  name               = "${var.cluster_name}-irsa-ebs"
  assume_role_policy = data.aws_iam_policy_document.ebs_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "ebs_attach" {
  count      = var.create_irsa ? 1 : 0
  role       = aws_iam_role.irsa_ebs[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

##########################################
# Helm: Cluster Autoscaler
##########################################

resource "helm_release" "cluster_autoscaler" {
  count      = var.install_autoscaler ? 1 : 0
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = "kube-system"

  set {
    name  = "autoDiscovery.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "Region"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.create_irsa ? aws_iam_role.irsa_cluster_autoscaler[0].arn : var.cluster_autoscaler_role_arn
  }

  depends_on = [aws_eks_cluster.this]
}

##########################################
# Helm: AWS Load Balancer Controller (ALB)
##########################################

resource "helm_release" "alb_controller" {
  count      = var.install_alb_controller ? 1 : 0
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.create_irsa ? aws_iam_role.irsa_alb[0].arn : var.alb_controller_role_arn
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  depends_on = [aws_eks_cluster.this]
}

############################################################
# EKS Addons
############################################################

# VPC CNI Addon (recommended by AWS)
resource "aws_eks_addon" "cni" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "vpc-cni"
}

# Kube-proxy Addon
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "kube-proxy"
}

# CoreDNS Addon
resource "aws_eks_addon" "coredns" {
  cluster_name = aws_eks_cluster.this.name
  addon_name   = "coredns"
}