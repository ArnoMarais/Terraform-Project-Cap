output "default_vpc_id" {
  value = data.aws_vpc.default_vpc.id
}

output "marais_a_gateway_id" {
  value = data.aws_internet_gateway.marais-a-gateway.id
}

output "region" {
  description = "AWS region the stack was deployed to"
  value       = var.region
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_arn" {
  description = "EKS cluster ARN"
  value       = module.eks.cluster_arn
}

output "eks_cluster_endpoint" {
  description = "Kubernetes API endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_cluster_version" {
  description = "Kubernetes version running on the control plane"
  value       = module.eks.cluster_version
}

output "eks_cluster_security_group_id" {
  description = "Cluster security group; the NodePort rule is attached to it"
  value       = module.eks.cluster_security_group_id
}

output "eks_node_group_name" {
  description = "Managed node group name"
  value       = module.eks.node_group_name
}

output "eks_subnet_ids" {
  description = "Subnets the cluster and nodes run in"
  value       = module.eks.subnet_ids
}

output "eks_nodeport" {
  description = "NodePort to browse to on a worker node's public IP"
  value       = var.nodeport
}

output "eks_kubeconfig_command" {
  description = "Run this to point kubectl at the cluster"
  value       = "aws eks update-kubeconfig --region ${var.region} --name ${module.eks.cluster_name}"
}

output "eks_deploy_nginx_command" {
  description = "Run from the repo root to deploy the nginx pod and NodePort service"
  value       = "kubectl apply -f ${local.nginx_manifest}"
}

output "eks_verify_command" {
  description = "Run to check the nginx pod, service and nodes"
  value       = "kubectl get nodes -o wide && kubectl get pods,svc -o wide"
}

output "eks_node_public_ips" {
  description = "Public IPs of the running worker nodes"
  value       = data.aws_instances.eks_nodes.public_ips
}

output "eks_nginx_urls" {
  description = "URLs to open in a browser to reach nginx on each worker node"
  value       = [for ip in data.aws_instances.eks_nodes.public_ips : "http://${ip}:${var.nodeport}"]
}
