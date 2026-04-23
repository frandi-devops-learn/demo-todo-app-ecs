resource "aws_lb" "demo_alb" {
  name               = var.alb_name
  internal           = "false"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.pub_subnets[*].id

  enable_deletion_protection = false # Set true for Production ALB

  tags = merge(local.common_tags, {
    Name = "${var.alb_name}"
  })
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = var.tg_name
  port        = 3000
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.vpc.id

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = 200
  }

  tags = merge(local.common_tags, {
    Name = "${var.tg_name}"
  })
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.demo_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}