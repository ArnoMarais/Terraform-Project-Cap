data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_internet_gateway" "marais-a-gateway" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default_vpc.id]
  }
}

data "aws_instances" "eks_nodes" {
  filter {
    name   = "tag:eks:nodegroup-name"
    values = [module.eks.node_group_name]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

