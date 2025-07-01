
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
  security_group_id = module.security_group.security_group_ec2
  subnet_id         = module.network.public_subnet_ids[0]
  ssh_public_key    = local.secrets.ssh_public_key
  database_name = local.secrets.database_name
  database_username = local.secrets.database_username
  database_password = local.secrets.database_password
  database_host = module.rds.database_host
  database_port = module.rds.database_port
}

module "aws_route53_record" {
  source       = "./modules/dns"
  domain_name  = var.domain_name
  dns_record   = module.ec2.public_ip
  aws_lb_dns_name = module.alb.aws_lb_dns_name
  aws_lb_zone_id = module.alb.aws_lb_zone_id
}

module "ssl_acm" {
  source       = "./modules/acm"
  domain_name  = var.domain_name
  route53_zone = module.aws_route53_record.aws_route53_zone_name
  aws_route53_zone_id = module.aws_route53_record.aws_route53_zone_id
}

module "alb" {
    source = "./modules/alb"
    acm_certificate_arn = module.ssl_acm.aws_acm_certificate_arn
    aws_acm_certificate_cert = module.ssl_acm.aws_acm_certificate_cert
    subnets = module.network.public_subnet_ids
    vpc_id = module.network.vpc_id
    security_group = module.security_group.security_group_alb
    ec2_instance_id = module.ec2.instance_id
}

module "rds" {
    source = "./modules/rds"
    security_group = module.security_group.security_group_rds
    database_name = local.secrets.database_name
    database_username = local.secrets.database_username
    database_password = local.secrets.database_password
    private_subnet_ids = module.network.private_subnet_ids
    public_subnet_ids = module.network.public_subnet_ids
}