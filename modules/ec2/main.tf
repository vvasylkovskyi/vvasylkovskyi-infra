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

  user_data = var.user_data
}



resource "aws_eip" "portfolio" {
  instance = aws_instance.portfolio.id
  domain   = "vpc"
}
