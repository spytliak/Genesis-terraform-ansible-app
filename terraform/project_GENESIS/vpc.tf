#-----------------------------------------------------------------------
# Module
#-----------------------------------------------------------------------
# AWS VPC
#-----------------------------------------------------------------------
module "vpc_genesis" {
  source = "../modules/vpc_genesis"

  env                  = var.env
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.privet_subnet_cidrs
}