module "vpc" {
  source = "./modules/VPC"

  vpc_cidr = var.vpc_cidr

  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "rds" {
  source = "./modules/RDS"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  db_username = var.db_username
  db_password = var.db_password
}

module "ec2" {
  source = "./modules/EC2"

  vpc_id    = module.vpc.vpc_id
  subnet_id = module.vpc.public_subnets[0]
}

module "ecr" {
  source = "./modules/ECR"

  repo_name = "devops-app"
}