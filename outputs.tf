# --- Load Balancer Information ---
output "alb_dns_name" {
  description = "The DNS name of the Load Balancer (use this to access the app)"
  value       = aws_lb.demo_alb.dns_name
}

output "alb_zone_id" {
  description = "The Zone ID of the Load Balancer"
  value       = aws_lb.demo_alb.zone_id
}

# --- Database Information ---
output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.rds.address
}

output "db_secret_arn" {
  description = "The ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_db_instance.rds.master_user_secret[0].secret_arn
}

# --- ECR Information ---
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.demo_ecr.repository_url
}

# --- ECS Cluster Information ---
output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.main.name
}

# --- VPC Information ---
output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.vpc.id
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets"
  value       = aws_subnet.priv_subnets[*].id
}