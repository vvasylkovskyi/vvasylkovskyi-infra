
module "network" {
  source            = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/network?ref=main"
  vpc_cidr          = "10.0.0.0/16"
  subnet_cidr       = "10.0.1.0/24"
  availability_zone = var.availability_zone
}

module "security_group" {
  source = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/security_group?ref=main"
  vpc_id = module.network.vpc_id
}

module "ec2" {
  source              = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/ec2?ref=main"
  instance_ami        = var.instance_ami
  instance_type       = var.instance_type
  availability_zone   = var.availability_zone
  security_group_id   = module.security_group.security_group_ec2
  subnet_id           = module.network.public_subnet_ids[0]
  ssh_public_key      = module.secrets.secrets.ssh_public_key
  ssh_public_key_name = "ec2-instance-key"

  depends_on = []

  user_data = <<-EOF
            #!/bin/bash
            sudo apt-get update -y
            sudo apt-get install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker

            # Add user to docker group
            sudo usermod -aG docker $USERNAME

            docker network create docker-internal-network

            sudo docker run -d --name video-service --network docker-internal-network \
              -p 4000:4000 \
              vvasylkovskyi1/vvasylkovskyi-cloud-meter-backend-api:${var.docker_image_hash_cloud_meter_backend_api}
            EOF
}

module "api_gateway" {
  source              = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/api-gateway?ref=main"
  api_name            = "cloudmeter-backend-gateway-api"
  domain_name         = var.domain_name
  acm_certificate_arn = module.ssl_acm.aws_acm_certificate_arn
  ec2_public_url      = "http://${module.ec2.public_ip}:4000"
}

# module "cloudfront_cdn" {
#   source          = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/cloudfront?ref=main"
#   acm_certificate_arn = module.ssl_acm.aws_acm_certificate_arn
#   route53_zone_id     = module.aws_route53_record.aws_route53_zone_id
#   domain_name         = var.route53_zone_name
#   ec2_public_ip       = module.ec2.public_ip
#   alb_dns_name        = module.alb.dns_name
#   alb_zone_id        = module.alb.zone_id
# }

module "aws_route53_record" {
  source          = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/dns?ref=main"
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_name
  dns_record      = module.ec2.public_ip
  aws_dns_name    = module.alb.dns_name
  aws_zone_id     = module.alb.zone_id
}

module "ssl_acm" {
  source              = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/acm?ref=main"
  domain_name         = var.domain_name
  aws_route53_zone_id = module.aws_route53_record.aws_route53_zone_id
}

# module "rds" {
#   source             = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/rds?ref=main"
#   security_group     = module.security_group.security_group_rds
#   database_name      = module.secrets.secrets.postgres_database_name
#   database_username  = module.secrets.secrets.postgres_database_username
#   database_password  = module.secrets.secrets.postgres_database_password
#   private_subnet_ids = module.network.private_subnet_ids
#   public_subnet_ids  = module.network.public_subnet_ids
#   database_identifier = "postgres-db"
#   database_engine    = "postgres"
#   database_engine_version = "15"
#   db_private_subnet_group_name = "postgres_rds-private-subnet-group"
#   db_public_subnet_group_name = "postgres_rds-public-subnet-group"
# }

module "secrets" {
  source           = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/secrets?ref=main"
  credentials_name = var.credentials_name
}
