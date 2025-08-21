
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
              -e DB_USER=${module.secrets.secrets.postgres_database_username} \
              -e DB_PASSWORD=${module.secrets.secrets.postgres_database_password} \
              -e DB_DATABASE_NAME=${module.secrets.secrets.postgres_database_name} \
              -e DB_HOST=${module.rds.database_host} \
              -e DB_PORT=${module.rds.database_port} \
              -e AWS_IOT_CORE_ENDPOINT=${module.secrets.secrets.aws_iot_core_endpoint} \
              -e AWS_IOT_CLIENT_ID=${module.secrets.secrets.aws_iot_client_id} \
              -e AWS_IOT_MQTT_TOPIC=${module.secrets.secrets.aws_iot_mqtt_topic} \
              -e AWS_IOT_CERT_BASE64=${module.secrets.secrets.aws_iot_cert_base64} \
              -e AWS_IOT_KEY_BASE64=${module.secrets.secrets.aws_iot_key_base64} \
              -e AWS_IOT_ROOT_CERT_BASE64=${module.secrets.secrets.aws_iot_root_cert_base64} \
              -e AWS_IOT_PATH_TO_CERT=${module.secrets.secrets.aws_iot_path_to_cert} \
              -e AWS_IOT_PATH_TO_KEY=${module.secrets.secrets.aws_iot_path_to_key} \
              -e AWS_IOT_PATH_TO_ROOT_CERT=${module.secrets.secrets.aws_iot_path_to_root_cert} \
              -e CLERK_JWKS_URL=${module.secrets.secrets.clerk_jwks_url} \
              vvasylkovskyi1/vvasylkovskyi-video-service-web:${var.docker_image_hash_video_service}

            sudo docker run -d --name frontend --network docker-internal-network -p 80:80 \
              -e DB_USER=${module.secrets.secrets.postgres_database_username} \
              -e DB_PASSWORD=${module.secrets.secrets.postgres_database_password} \
              -e DB_DATABASE_NAME=${module.secrets.secrets.postgres_database_name} \
              -e DB_HOST=${module.rds.database_host} \
              -e DB_PORT=${module.rds.database_port} \
              -e VIDEO_SERVICE_URL=${var.video_service_url} \
              -e NEXT_PUBLIC_POSTHOG_KEY=${module.secrets.secrets.posthog_key} \
              -e NEXT_PUBLIC_POSTHOG_HOST=${module.secrets.secrets.posthog_host} \
              -e METERED_API_KEY_TURN_CREDENTIALS=${module.secrets.secrets.metered_api_key_turn_credentials} \
              -e NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=${module.secrets.secrets.clerk_api_key_publishable_key} \
              -e CLERK_SECRET_KEY=${module.secrets.secrets.clerk_api_key_secret_key} \
              -e NEXT_PUBLIC_CLERK_SIGN_IN_URL=/sign-in \
              -e NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/ \
              -e NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/ \
              -e NEXT_PUBLIC_CLERK_SIGN_UP_URL=/sign-up \
              -e NEXT_PUBLIC_CLERK_SIGN_UP_FALLBACK_REDIRECT_URL=/ \
              -e NEXT_PUBLIC_CLERK_SIGN_IN_FALLBACK_REDIRECT_URL=/ \
              vvasylkovskyi1/vvasylkovskyi-portfolio:${var.docker_image_hash_portfolio_fe}
            EOF
}

# module "api_gateway" {
#   source              = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/api-gateway?ref=main"
#   api_name            = "portfolio-gateway-api"
#   domain_name         = var.domain_name
#   acm_certificate_arn = module.ssl_acm.aws_acm_certificate_arn
#   ec2_public_url      = "http://${module.ec2.public_ip}:80"
# }

module "cloudfront_cdn" {
  acm_certificate_arn = module.ssl_acm.aws_acm_certificate_arn
  route53_zone_id     = module.aws_route53_record.aws_route53_zone_id
  ec2_public_ip       = module.ec2.public_ip
  domain_name         = var.domain_name
}

module "aws_route53_record" {
  source          = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/dns?ref=main"
  domain_name     = var.domain_name
  route53_zone_id = var.route53_zone_id
  dns_record      = module.ec2.public_ip
  aws_dns_name    = module.cloudfront_cdn.domain_name
  aws_zone_id     = module.cloudfront_cdn.hosted_zone_id
}

# Clerk Authentication Provider DNS 
variable "clerk_cname_records" {
  type = map(string)
  default = {
    clerk          = "frontend-api.clerk.services"
    accounts       = "accounts.clerk.services"
    clkmail        = "mail.6dzf3jivhtew.clerk.services"
    "clk._domainkey"  = "dkim1.6dzf3jivhtew.clerk.services"
    "clk2._domainkey" = "dkim2.6dzf3jivhtew.clerk.services"
  }
}

resource "aws_route53_record" "clerk_cname" {
  for_each = var.clerk_cname_records

  zone_id = module.aws_route53_record.aws_route53_zone_id
  name    = each.key
  type    = "CNAME"
  ttl     = 300
  records = [each.value]
}

module "ssl_acm" {
  source              = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/acm?ref=main"
  domain_name         = var.domain_name
  aws_route53_zone_id = module.aws_route53_record.aws_route53_zone_id
}

# module "alb" {
#   source                   = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/alb?ref=main"
#   acm_certificate_arn      = module.ssl_acm.aws_acm_certificate_arn
#   aws_acm_certificate_cert = module.ssl_acm.aws_acm_certificate_cert
#   subnets                  = module.network.public_subnet_ids
#   vpc_id                   = module.network.vpc_id
#   security_group           = module.security_group.security_group_alb
#   ec2_instance_id          = module.ec2.instance_id
#   alb_name                 = var.alb_name
# }

module "rds" {
  source             = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/rds?ref=main"
  security_group     = module.security_group.security_group_rds
  database_name      = module.secrets.secrets.postgres_database_name
  database_username  = module.secrets.secrets.postgres_database_username
  database_password  = module.secrets.secrets.postgres_database_password
  private_subnet_ids = module.network.private_subnet_ids
  public_subnet_ids  = module.network.public_subnet_ids
  database_identifier = "postgres-db"
  database_engine    = "postgres"
  database_engine_version = "15"
  db_private_subnet_group_name = "postgres_rds-private-subnet-group"
  db_public_subnet_group_name = "postgres_rds-public-subnet-group"
}

module "secrets" {
  source           = "git::https://github.com/vvasylkovskyi/vvasylkovskyi-infra.git//modules/secrets?ref=main"
  credentials_name = var.credentials_name
}
