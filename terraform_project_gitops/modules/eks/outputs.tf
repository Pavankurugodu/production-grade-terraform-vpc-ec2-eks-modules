output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "cluster_id" {
  value = aws_eks_cluster.this.id
}

output "cluster_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.this.certificate_authority[0].data
}

output "node_group_name" {
  value = aws_eks_node_group.managed.node_group_name
}

output "irsa_roles" {
  value = {
    cluster_autoscaler = try(aws_iam_role.irsa_cluster_autoscaler[0].arn, "")
    alb_controller     = try(aws_iam_role.irsa_alb[0].arn, "")
    ebs_csi            = try(aws_iam_role.irsa_ebs[0].arn, "")
  }
}
