locals {
  services = ["ecr.dkr", "ecr.api", "logs", "ssmmessages"]
}

resource "aws_vpc_endpoint" "demo_interfaces" {
  for_each            = toset(local.services)
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.ap-southeast-1.${each.value}"
  vpc_endpoint_type   = var.endpoint_type_1
  private_dns_enabled = var.dns_enable
  subnet_ids          = aws_subnet.priv_subnets[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]

  tags = merge(local.common_tags, {
    Name = "demo-todo-endpoint-${each.value}"
  })
}

resource "aws_vpc_endpoint" "demo_s3_gw" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.ap-southeast-1.s3"
  vpc_endpoint_type = var.endpoint_type_2
  route_table_ids   = [aws_route_table.priv_rtb.id]

  tags = merge(local.common_tags, {
    Name = "demo-todo-endpoint-s3"
  })
}