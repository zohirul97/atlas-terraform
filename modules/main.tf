module "vpc" {
  source = "./vpc"
}

module "sg" {
  source = "./security_groups"

  vpc_id = module.vpc.vpc_id
}