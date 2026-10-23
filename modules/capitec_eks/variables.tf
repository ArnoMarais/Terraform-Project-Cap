variable "prefix" {
  description = "Owner prefix in the form <surname>-<first_initial>"
  type        = string
}

variable "environment" {
  description = "Environment to deploy: dev, qa or prod"
  type        = string

  validation {
    condition     = contains(["dev", "qa", "prod"], var.environment)
    error_message = "environment must be dev, qa or prod."
  }
}

variable "vpc_id" {
  type = string
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "AZ name => CIDR for this learner's subnets"
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS worker nodes: ON_DEMAND or SPOT"
  type        = string
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during a node group update"
  type        = number
}

variable "nodeport" {
  description = "NodePort exposed on the worker nodes for the nginx service"
  type        = number
}

variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to reach the NodePort"
  type        = list(string)
}
