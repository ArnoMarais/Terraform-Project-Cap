##s3 bucket from module
variable "environment" {}
variable "prefix" {}
variable "enable_versioning" {}

# module "s3"{
#     source = "./modules/capitec_s3"
#     environment = var.environment
#     enable_versioning = var.enable_versioning
# }

##eks from our custom module
module "eks"{
    source = "./modules/capitec_eks"
    environment = var.environment
    prefix = var.prefix
}




