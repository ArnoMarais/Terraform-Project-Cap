
locals {
  eks_cluster_name = "${var.prefix}-eks-${var.environment}"
  iam_role_name    = "${var.prefix}-eks-iam-role-${var.environment}"
}