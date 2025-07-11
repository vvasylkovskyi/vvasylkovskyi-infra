resource "aws_db_subnet_group" "default" {
  name       = var.db_private_subnet_group_name
  subnet_ids = [for id in var.private_subnet_ids : id]
}

resource "aws_db_subnet_group" "public" {
  name       = var.db_public_subnet_group_name
  subnet_ids = [for id in var.public_subnet_ids : id]
}

resource "aws_db_instance" "database" {
  identifier         = var.database_identifier
  engine             = var.database_engine
  engine_version     = var.database_engine_version
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