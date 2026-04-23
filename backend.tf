terraform {
  backend "s3" {
    bucket  = "demo-todo-app-terraform-state"
    region  = "ap-southeast-1"
    key     = "demo-todo-ecs/terraform.tfstate"
    encrypt = true
  }
}