variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
}
variable "vpc_name" {
  description = "Define name for vpc"
  type        = string
}

variable "instance_tenancy" {
  description = "A tenancy option for instances launched into the VPC. Valid values are default and dedicated."
  type        = string
}

variable "dns_support" {
  description = "A boolean flag to enable/disable DNS support in the VPC. Valid values are true and false."
  type        = bool
}

variable "dns_hostnames" {
  description = "A boolean flag to enable/disable DNS hostnames in the VPC. Valid values are true and false."
  type        = bool
}

variable "azs" {
  description = "AZ for vpc"
  type        = list(string)
}

variable "vpc_priv_subnets" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "priv_name" {
  description = "Name for private subnets"
  type        = string
}

variable "vpc_pub_subnets" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
}

variable "pub_name" {
  description = "Name for public subnets"
  type        = string
}

variable "rtb_cidr" {
  description = "CIDR block for route table"
  type        = string
}

variable "rtb_name" {
  description = "Name for route table"
  type        = string
}

variable "igw_name" {
  description = "Name for internet gateway"
  type        = string
}

variable "map_public" {
  description = "Map Public IP"
  type        = bool
}

variable "endpoint_type_1" {
  description = "Endpoint type for VPC"
  type        = string
}

variable "endpoint_type_2" {
  description = "Endpoint type for VPC"
  type        = string
}

variable "dns_enable" {
  description = "Private DNS enable for ECR"
  type        = bool
}

variable "rds_sg" {
  type        = string
  description = "RDS Name"
}

variable "backend_ecs_sg" {
  type        = string
  description = "Backend ECS SG Name"
}

variable "alb_sg" {
  type        = string
  description = "ALB Name"
}

variable "endpoint_sg" {
  type        = string
  description = "Endpoint Name"
}

variable "rds_priv" {
  type        = string
  description = "Private subnet for RDS"
}

variable "rds_name" {
  type        = string
  description = "RDS Name"
}

variable "db_name" {
  type        = string
  description = "DB Name"
}

variable "engine" {
  type        = string
  description = "RDS Engine"
}

variable "engine_version" {
  type        = string
  description = "RDS Engine Version"
}

variable "db_class" {
  type        = string
  description = "RDS Class"
}

variable "user" {
  type        = string
  description = "RDS User Name"
}

variable "encrypt" {
  type        = bool
  description = "Storage Encrypt for RDS"
}

variable "storage_type" {
  type        = string
  description = "Storage Type for RDS"
}

variable "storage" {
  type        = string
  description = "Total Storage size for RDS"
}

variable "multi" {
  type        = string
  description = "Multi AZs for RDS"
}

variable "public" {
  type        = string
  description = "Public Access for RDS"
}

variable "skip" {
  type        = string
  description = "Skip Snapshot for RDS"
}

variable "final" {
  type        = string
  description = "Final Snapshot for RDS"
}

variable "apply" {
  type        = string
  description = "Apply immediately for RDS"
}

variable "max" {
  type        = string
  description = "Max Storage for RDS"
}

variable "ecr_name" {
  type        = string
  description = "ECR Name"
}

variable "image" {
  type        = string
  description = "Mutability for EC"
}

variable "scan" {
  type        = bool
  description = "Scan on push docker image"
}

variable "encrypt_type" {
  type        = string
  description = "Encryption for ECR"
}

variable "alb_name" {
  type        = string
  description = "Application Loadbalancer Name"
}

variable "tg_name" {
  type        = string
  description = "ALB's target Group Name"
}

variable "github_repo" {
  type        = string
  description = "GitHub repository name"
}

variable "force_delete" {
  type        = bool
  description = "Delete ECR even existing images"
}