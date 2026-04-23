# 1. Create the OIDC Provider for GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"] # Standard GitHub OIDC thumbprint
}

# 2. Create the IAM Role for GitHub Actions
resource "aws_iam_role" "demo-todo-github_actions_role" {
  name = "demo-todo-github-oidc-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:${var.github_repo}:*"
          }
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
        }
      }
    ]
  })
}

# 3. Attach necessary policies (ECR access)
resource "aws_iam_role_policy_attachment" "ecr_power_user" {
  role       = aws_iam_role.demo-todo-github_actions_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

# 4. Optional: Add ECS deployment permissions
resource "aws_iam_role_policy" "ecs_deploy" {
  name = "ecs-deploy-policy"
  role = aws_iam_role.demo-todo-github_actions_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["ecs:UpdateService", "ecs:DescribeServices"]
      Resource = [aws_ecs_service.backend_service.arn]
    }]
  })
}