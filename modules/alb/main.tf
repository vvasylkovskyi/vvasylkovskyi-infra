resource "aws_lb" "portfolio" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.security_group]
  subnets            = var.subnets
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.portfolio.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.portfolio.arn
  }

  depends_on = [var.aws_acm_certificate_cert]
}

resource "aws_lb_target_group" "portfolio" {
  name     = "${var.alb_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 15
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }

  depends_on = [aws_lb.portfolio]
}

resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = aws_lb_target_group.portfolio.arn
  target_id        = var.ec2_instance_id
  port             = 80
}
