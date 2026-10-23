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

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "af-south-1"
}

variable "app_name" {
  description = "Value for the APP default tag"
  type        = string
  default     = "capitec-terraform-training"
}

variable "owner" {
  description = "Value for the Owner default tag"
  type        = string
  default     = "Geeks4Learning"
}

variable "learner_key" {
  description = "Key in learner_subnets.json that holds this learner's subnets"
  type        = string
  default     = "marias-a"
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string
  default     = "1.35"
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string
  default     = "t3.small"
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS worker nodes: ON_DEMAND or SPOT"
  type        = string
  default     = "ON_DEMAND"

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 1
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 2
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during a node group update"
  type        = number
  default     = 1
}

variable "nodeport" {
  description = "NodePort exposed on the worker nodes for the nginx service"
  type        = number
  default     = 30007
}

variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to reach the NodePort"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
