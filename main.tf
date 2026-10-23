# module "s3"{
#     source = "./modules/capitec_s3"
#     environment = var.environment
#     enable_versioning = var.enable_versioning
# }

##eks from our custom module
module "eks" {
  source       = "./modules/capitec_eks"
  environment  = var.environment
  prefix       = var.prefix
  vpc_id       = data.aws_vpc.default_vpc.id
  subnet_cidrs = local.learner.subnets

  eks_version          = var.eks_version
  node_instance_type   = var.node_instance_type
  node_capacity_type   = var.node_capacity_type
  node_min_size        = var.node_min_size
  node_desired_size    = var.node_desired_size
  node_max_size        = var.node_max_size
  node_max_unavailable = var.node_max_unavailable
  nodeport             = var.nodeport
  nodeport_cidr_blocks = var.nodeport_cidr_blocks
}




