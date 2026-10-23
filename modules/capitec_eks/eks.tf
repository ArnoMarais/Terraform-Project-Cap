
resource "aws_subnet" "eks_subnets" {
  for_each = var.subnet_cidrs

  vpc_id                  = var.vpc_id
  cidr_block              = var.subnet_cidrs[each.key]
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.prefix}-subnet-${each.key}-${var.environment}"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_route_table_association" "public_route_table_association" {
  for_each = aws_subnet.eks_subnets

  subnet_id      = each.value.id
  route_table_id = data.aws_route_table.route_table_lookup.id
}

resource "aws_eks_cluster" "eks_cluster" {
  name = local.eks_cluster_name

  access_config {
    authentication_mode = "API"
    #bootstrap_cluster_creator_admin_permissions = true
  }

  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_version

  vpc_config {
    subnet_ids = [for s in aws_subnet.eks_subnets : s.id]
  }

  # Ensure that IAM Role permissions are created before and deleted
  # after EKS Cluster handling. Otherwise, EKS will not be able to
  # properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
  ]

  tags = {
    Name = local.eks_cluster_name
  }
}

resource "aws_iam_role" "eks_cluster_role" {
  name               = local.iam_role_name
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role.json
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

# authentication_mode = "API" means Kubernetes RBAC access is governed
# entirely by EKS access entries, not IAM policies or aws-auth. Without
# this, the IAM principal that creates/manages the cluster has no way
# to authenticate to the Kubernetes API.
data "aws_caller_identity" "current" {}

# Access entries need the IAM role or user ARN. aws_caller_identity returns the
# assumed-role session ARN when running via OIDC (CI) or SSO, which AWS rejects.
# This resolves the session back to its IAM role. For IAM users it returns the user ARN.
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = data.aws_iam_session_context.current.issuer_arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  principal_arn = aws_eks_access_entry.admin.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_iam_role" "node" {
  name               = "${var.prefix}-eks-node-role-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}

resource "aws_iam_role_policy_attachment" "node_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}

resource "aws_security_group_rule" "nodeport_ingress" {
  type              = "ingress"
  from_port         = var.nodeport
  to_port           = var.nodeport
  protocol          = "tcp"
  cidr_blocks       = var.nodeport_cidr_blocks
  security_group_id = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  description       = "Allow inbound access to nginx NodePort service"
}

resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.prefix}-eks-nodes-${var.environment}"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = [for s in aws_subnet.eks_subnets : s.id]

  capacity_type  = var.node_capacity_type
  instance_types = [var.node_instance_type]

  scaling_config {
    min_size     = var.node_min_size
    max_size     = var.node_max_size
    desired_size = var.node_desired_size
  }

  update_config {
    max_unavailable = var.node_max_unavailable
  }

  lifecycle {
    precondition {
      condition     = var.node_min_size <= var.node_desired_size && var.node_desired_size <= var.node_max_size
      error_message = "Node sizes must satisfy node_min_size <= node_desired_size <= node_max_size."
    }
  }

  # Ensure IAM permissions are created before and deleted after the
  # node group, otherwise EKS cannot properly bootstrap/tear down nodes.
  depends_on = [
    aws_iam_role_policy_attachment.node_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.node_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.node_AmazonEC2ContainerRegistryReadOnly,
  ]
}
