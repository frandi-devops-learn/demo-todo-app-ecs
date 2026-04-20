resource "aws_security_group" "alb_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.alb_sg
  description = "Allow HTTPS Connection to ALB"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS Connection to ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.alb_sg}"
  })
}

resource "aws_security_group" "backend_ecs_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.backend_ecs_sg
  description = "Allow Backend ECS Connection from ALB"

  ingress {
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description     = "Allow Backend ECS Connection from ALB"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.backend_ecs_sg}"
  })
}


resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.rds_sg
  description = "Allow RDS Connection from Backend ECS"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs_sg.id]
    description     = "Allow RDS Connection from Backend ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.rds_sg}"
  })
}

resource "aws_security_group" "vpc_endpoint_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = var.endpoint_sg
  description = "Allow ECS tasks to reach VPC Endpoints"

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_ecs_sg.id]
    description     = "Allow HTTPS from Backend ECS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${var.endpoint_sg}"
  })
}