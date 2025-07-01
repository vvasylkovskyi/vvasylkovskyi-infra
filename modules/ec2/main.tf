resource "aws_key_pair" "ssh-key" {
  key_name   = "ec2-instance-key"
  public_key = var.ssh_public_key
}

resource "aws_instance" "portfolio" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  availability_zone           = var.availability_zone
  security_groups             = [var.security_group_id]
  associate_public_ip_address = true
  subnet_id                   = var.subnet_id
  key_name                    = aws_key_pair.ssh-key.key_name
  
  depends_on = [var.database_host]
  
  user_data = <<-EOF
            #!/bin/bash
            sudo yum update -y || sudo apt-get update -y
            sudo yum install -y docker || sudo apt-get install -y docker.io
            sudo systemctl start docker
            sudo systemctl enable docker
            sudo docker run -d -p 80:80 \
              -e DB_USER=${var.database_username} \
              -e DB_PASSWORD=${var.database_password} \
              -e DB_DATABASE_NAME=${var.database_name} \
              -e DB_HOST=${var.database_host} \
              -e DB_PORT=${var.database_port} \
              vvasylkovskyi1/vvasylkovskyi-portfolio:latest
            EOF
}



resource "aws_eip" "portfolio" {
  instance = aws_instance.portfolio.id
  domain   = "vpc"
}