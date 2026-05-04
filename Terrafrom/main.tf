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
resource "null_resource" "ansible" {

  depends_on = [module.ec2]

  provisioner "local-exec" {
    command = <<EOT
      echo "[web]" > ../ansible/inventory.ini
      echo "${module.ec2.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/devops-key.pem" >> ../ansible/inventory.ini
      sleep 60
      ansible-playbook -i ../ansible/inventory.ini ../ansible/playbook.yml
    EOT
  }
}

module "ecr" {
  source = "./modules/ECR"

  repo_name = "devops-app"
}