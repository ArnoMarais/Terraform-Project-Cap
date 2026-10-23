output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.eks_cluster.name
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.eks_cluster.arn
}

output "cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = aws_eks_cluster.eks_cluster.endpoint
}

output "cluster_version" {
  description = "Kubernetes version running on the control plane"
  value       = aws_eks_cluster.eks_cluster.version
}

output "cluster_certificate_authority_data" {
  description = "Base64 CA certificate for the cluster API"
  value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
  sensitive   = true
}

output "cluster_security_group_id" {
  description = "Cluster security group; the NodePort rule is attached to it"
  value       = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

output "cluster_role_arn" {
  description = "IAM role used by the EKS control plane"
  value       = aws_iam_role.eks_cluster_role.arn
}

output "node_group_name" {
  description = "Managed node group name"
  value       = aws_eks_node_group.main.node_group_name
}

output "node_role_arn" {
  description = "IAM role used by the worker nodes"
  value       = aws_iam_role.node.arn
}

output "subnet_ids" {
  description = "Subnets the cluster and nodes run in"
  value       = [for s in aws_subnet.eks_subnets : s.id]
}


