resource "aws_ecr_repository" "demo_ecr" {
  name                 = var.ecr_name
  image_tag_mutability = var.image

  image_scanning_configuration {
    scan_on_push = var.scan
  }

  encryption_configuration {
    encryption_type = var.encrypt_type
  }

  force_delete = var.force_delete

  tags = merge(local.common_tags, {
    Name = "${var.ecr_name}"
  })
}

resource "aws_ecr_lifecycle_policy" "cleanup_policy" {
  repository = aws_ecr_repository.demo_ecr.name

  policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Keep last 10 images"
      selection = {
        tagStatus   = "any"
        countType   = "imageCountMoreThan"
        countNumber = 10
      }
      action = {
        type = "expire"
      }
    }]
  })
}