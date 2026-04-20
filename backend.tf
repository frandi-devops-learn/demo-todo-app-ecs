terraform {
  backend "s3" {
    bucket  = "demo-todo-app-terraform"
    region  = "ap-southeast-1"
    key     = "demo-sms-ecs/terraform.tfstate"
    encrypt = true
  }
}