variable "prefix" {
  description = "Owner prefix in the form <surname>-<first_initial>"
  type        = string

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+$", var.prefix))
    error_message = "prefix must look like marais-a (lowercase surname, dash, initial)."
  }
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

  validation {
    condition     = can(regex("^vpc-[0-9a-f]+$", var.vpc_id))
    error_message = "vpc_id must be a VPC ID such as vpc-0123456789abcdef0."
  }
}

variable "subnet_cidrs" {
  type        = map(string)
  description = "AZ name => CIDR for this learner's subnets"

  validation {
    condition     = length(var.subnet_cidrs) >= 2 && alltrue([for c in values(var.subnet_cidrs) : can(cidrhost(c, 0))])
    error_message = "subnet_cidrs must hold at least two valid CIDR blocks, one per AZ (EKS requires two AZs)."
  }
}

variable "eks_version" {
  description = "Kubernetes version for the EKS control plane"
  type        = string

  validation {
    condition     = can(regex("^1\\.[0-9]+$", var.eks_version))
    error_message = "eks_version must be a minor version such as 1.35."
  }
}

variable "node_instance_type" {
  description = "EC2 instance type for the EKS worker nodes"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]*\\.[a-z0-9]+$", var.node_instance_type))
    error_message = "node_instance_type must be an EC2 instance type such as t3.small."
  }
}

variable "node_capacity_type" {
  description = "Capacity type for the EKS worker nodes: ON_DEMAND or SPOT"
  type        = string

  validation {
    condition     = contains(["ON_DEMAND", "SPOT"], var.node_capacity_type)
    error_message = "node_capacity_type must be ON_DEMAND or SPOT."
  }
}

variable "node_min_size" {
  description = "Minimum number of worker nodes"
  type        = number

  validation {
    condition     = var.node_min_size >= 1
    error_message = "node_min_size must be at least 1."
  }
}

variable "node_desired_size" {
  description = "Desired number of worker nodes"
  type        = number

  validation {
    condition     = var.node_desired_size >= 1
    error_message = "node_desired_size must be at least 1."
  }
}

variable "node_max_size" {
  description = "Maximum number of worker nodes"
  type        = number

  validation {
    condition     = var.node_max_size >= 1
    error_message = "node_max_size must be at least 1."
  }
}

variable "node_max_unavailable" {
  description = "Maximum number of nodes unavailable during a node group update"
  type        = number

  validation {
    condition     = var.node_max_unavailable >= 1
    error_message = "node_max_unavailable must be at least 1."
  }
}

variable "nodeport" {
  description = "NodePort exposed on the worker nodes for the nginx service"
  type        = number

  validation {
    condition     = var.nodeport >= 30000 && var.nodeport <= 32767
    error_message = "nodeport must be between 30000 and 32767 (the Kubernetes NodePort range)."
  }
}

variable "nodeport_cidr_blocks" {
  description = "CIDR blocks allowed to reach the NodePort"
  type        = list(string)

  validation {
    condition     = length(var.nodeport_cidr_blocks) > 0 && alltrue([for c in var.nodeport_cidr_blocks : can(cidrhost(c, 0))])
    error_message = "nodeport_cidr_blocks must contain at least one valid CIDR block."
  }
}
