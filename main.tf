
module "network" {
  source            = "./modules/network"
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = var.availability_zone
}

module "security_group" {
  source = "./modules/security_group"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source            = "./modules/ec2"
  instance_ami      = var.instance_ami
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  security_group_id = module.security_group.security_group_id
  subnet_id         = module.network.subnet_id
  ssh_public_key    = local.secrets.ssh_public_key
}

module "aws_route53_record" {
  source       = "./modules/dns"
  domain_name  = var.domain_name
  dns_record   = module.ec2.public_ip
}