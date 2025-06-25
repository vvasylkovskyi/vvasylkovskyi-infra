resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_subnet" "portfolio" {
  cidr_block        = var.subnet_cidr
  vpc_id            = aws_vpc.main.id
  availability_zone = var.availability_zone
}

resource "aws_internet_gateway" "portfolio" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "portfolio" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.portfolio.id
  }
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = aws_subnet.portfolio.id
  route_table_id = aws_route_table.portfolio.id
}