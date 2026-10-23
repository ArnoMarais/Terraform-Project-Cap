region               = "af-south-1"
app_name             = "capitec-terraform-training"
owner                = "Geeks4Learning"
eks_version          = "1.35"
node_capacity_type   = "ON_DEMAND"
node_max_unavailable = 1
nodeport             = 30007
nodeport_cidr_blocks = ["0.0.0.0/0"]
