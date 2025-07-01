resource "aws_db_subnet_group" "default" {
  name       = "rds-private-subnet-group"
  subnet_ids = [for id in var.private_subnet_ids : id]

  tags = {
    Name = "RDS Private Subnet Group"
  }
}

resource "aws_db_subnet_group" "public" {
  name       = "rds-public-subnet-group"
  subnet_ids = [for id in var.public_subnet_ids : id]

  tags = {
    Name = "RDS Public Subnet Group"
  }
}

resource "aws_db_instance" "postgres" {
  identifier         = "postgres-db"
  engine             = "postgres"
  engine_version     = "15"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  storage_type       = "gp2"
  username           = var.database_username
  password           = var.database_password
  db_name            = var.database_name
  vpc_security_group_ids = [var.security_group]
  db_subnet_group_name = aws_db_subnet_group.public.name
  skip_final_snapshot    = true # for dev; not recommended in prod
  publicly_accessible = true
}