vpc_name = "demo-todo-app"

instance_tenancy = "default"

dns_hostnames = true

dns_support = true

cidr_block = "192.168.0.0/16"

azs = ["ap-southeast-1a", "ap-southeast-1b"]

vpc_priv_subnets = ["192.168.1.0/24", "192.168.2.0/24"]

priv_name = "demo-todo-priv-subnet"

vpc_pub_subnets = ["192.168.5.0/24", "192.168.6.0/24"]

pub_name = "demo-todo-pub-subnet"

rtb_cidr = "0.0.0.0/0"

rtb_name = "demo-todo"

igw_name = "demo-todo"

map_public = true

endpoint_type_1 = "Interface"

endpoint_type_2 = "Gateway"

dns_enable = true

rds_sg = "demo-sms-rds-sg"

backend_ecs_sg = "demo-todo-bk-sg"

alb_sg = "demo-todo-alb-sg"

endpoint_sg = "demo-todo-endpoint-sg"

rds_priv = "demo-todo-rds-subnet"

db_name = "uatdb"

rds_name = "demo-todo-rds"

engine = "postgres"

engine_version = "16.11"

db_class = "db.t4g.micro"

user = "dbadmin"

encrypt = true

storage_type = "gp3"

storage = "20"

multi = false

public = false

skip = true

final = false

apply = true

max = "50"

ecr_name = "demo-todo-bk"

image = "MUTABLE"

scan = true

encrypt_type = "AES256"