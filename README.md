# AWS Demo Application Infrastructure

This Terraform project deploys a containerized demo application on AWS using ECS Fargate, RDS PostgreSQL, Application Load Balancer, and supporting infrastructure. All resources are provisioned with security best practices including private subnets, encryption, and OIDC-based CI/CD.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                              AWS Cloud                           │
│                                                                  │
│  ┌──────────────┐                                               │
│  │   Internet    │                                               │
│  └──────┬───────┘                                               │
│         │                                                        │
│  ┌──────▼───────┐      ┌─────────────────────────────────────┐  │
│  │     ALB      │─────▶│         Public Subnets                │  │
│  │   (Port 80)  │      │  ┌─────────┐    ┌─────────┐          │  │
│  └──────────────┘      │  │  AZ-1a  │    │  AZ-1b  │          │  │
│                        │  └─────────┘    └─────────┘          │  │
│                        └─────────────────────────────────────┘  │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Private Subnets                          │ │
│  │  ┌─────────────────┐      ┌─────────────────┐               │ │
│  │  │   ECS Fargate   │      │   ECS Fargate   │               │ │
│  │  │   (Port 3000)   │◀────▶│   (Port 3000)   │               │ │
│  │  │  Auto-scaling   │      │  Auto-scaling   │               │ │
│  │  └────────┬────────┘      └────────┬────────┘               │ │
│  │           │                        │                         │ │
│  │           └──────────┬─────────────┘                         │ │
│  │                      ▼                                       │ │
│  │  ┌─────────────────────────────────────┐                    │ │
│  │  │      RDS PostgreSQL (Encrypted)      │                    │ │
│  │  │      Secrets Manager (Passwords)     │                    │ │
│  │  └─────────────────────────────────────┘                    │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │              VPC Endpoints (Private AWS Access)               ││
│  │  • ECR (dkr + api)  • CloudWatch Logs  • Secrets Manager   ││
│  │  • SSM + SSMMessages  • S3 Gateway  • KMS (optional)        ││
│  └────────────────────────────────────────────────────────────┘│
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐│
│  │              GitHub Actions CI/CD (OIDC)                      ││
│  │         Push Image → ECR  →  Deploy to ECS                   ││
│  └────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

---

## File Structure

| File | Purpose | Key Resources |
|------|---------|---------------|
| **`vpc.tf`** | Network foundation | VPC, public/private subnets, IGW, NAT, route tables |
| **`alb.tf`** | Traffic distribution | Application Load Balancer, target group, HTTP listener |
| **`rds.tf`** | Database layer | PostgreSQL RDS, subnet group, parameter group, encryption |
| **`security-group.tf`** | Firewall rules | ALB, ECS, RDS, VPC endpoint security groups |
| **`ecr.tf`** | Container registry | ECR repository, image scanning, lifecycle policy |
| **`endpoint.tf`** | Private AWS connectivity | Interface endpoints (ECR, Logs, Secrets, SSM), S3 gateway |
| **`iam-role.tf`** | Task permissions | ECS execution role, ECS task role, Secrets access |
| **`oidc.tf`** | CI/CD authentication | GitHub OIDC provider, deployment IAM role |
| **`ecs.tf`** | Container orchestration | ECS cluster, Fargate tasks, service, auto-scaling |
| **`outputs.tf`** | Deployment information | ALB DNS, RDS endpoint, ECR URL, resource IDs |

---

## Detailed File Explanations

### 1. `vpc.tf` — Virtual Private Cloud

**Purpose:** Creates the foundational network infrastructure.

**Key Components:**
- **VPC** with DNS hostnames/support enabled
- **Public Subnets** (2 AZs) with auto-assign public IPs for ALB
- **Private Subnets** (2 AZs) for ECS tasks and RDS
- **Internet Gateway** for public internet access
- **Route Tables** — public (via IGW) and private

**Security Notes:**
- RDS and ECS tasks reside in private subnets with no direct internet exposure
- VPC endpoints required for ECS tasks to pull images from Private ECR

---

### 2. `alb.tf` — Application Load Balancer

**Purpose:** Distributes incoming HTTP traffic to ECS tasks.

**Key Components:**
- **ALB** in public subnets with deletion protection disabled (enable for production)
- **Target Group** targeting ECS tasks on port 3000 with health checks (`/health`)
- **HTTP Listener** on port 80 forwarding to target group

**Important:** HTTPS (port 443) with ACM certificate is recommended for production. The current configuration uses HTTP for demo purposes. I used Cloudflare Domain for SSL/TLS.

---

### 3. `rds.tf` — Relational Database Service

**Purpose:** Managed PostgreSQL database for application data.

**Key Components:**
- **RDS Instance** (PostgreSQL 16) with encrypted storage
- **DB Subnet Group** placing RDS in private subnets
- **Parameter Group** with performance-tuned settings (max_connections, work_mem, autovacuum)
- **Secrets Manager Integration** — auto-generated master password

**Security Features:**
- Storage encryption enabled
- Private subnet placement (no public access)
- Master password managed by AWS Secrets Manager (no hardcoded credentials)

---

### 4. `security-group.tf` — Network Security

**Purpose:** Defines firewall rules for layered security.

**Security Groups:**
| SG | Allows From | Allows To | Purpose |
|----|-------------|-----------|---------|
| `alb_sg` | Internet (0.0.0.0/0) | ALB port 80 | Public web traffic |
| `backend_ecs_sg` | ALB SG | ECS port 3000 | ALB → ECS communication |
| `rds_sg` | ECS SG | RDS port 5432 | ECS → Database communication |
| `vpc_endpoint_sg` | ECS SG | Endpoint port 443 | ECS → AWS services |

**Architecture:** Layered defense with security group references (not CIDR blocks) for internal traffic.

---

### 5. `ecr.tf` — Elastic Container Registry

**Purpose:** Stores Docker images for ECS deployment.

**Key Components:**
- **ECR Repository** with image scanning on push
- **Encryption** (AES-256 or KMS)
- **Image Tag Mutability** — prevents accidental overwrites
- **Lifecycle Policy** — retains only last 10 images to control storage costs

---

### 6. `endpoint.tf` — VPC Endpoints

**Purpose:** Enables private communication with AWS services (no internet required).

**Interface Endpoints** (powered by AWS PrivateLink):
- `ecr.dkr` — Docker image pulls
- `ecr.api` — ECR API operations
- `logs` — CloudWatch Logs streaming
- `secretsmanager` — Database credential retrieval
- `ssm` — ECS Exec

**Gateway Endpoint:**
- `s3` — S3 access via route table (no ENI required)

**Benefit:** ECS tasks in private subnets can operate without NAT Gateway for AWS service access.

---

### 7. `iam-role.tf` — Identity and Access Management

**Purpose:** Defines permissions for ECS tasks and execution.

**Roles:**
| Role | Used By | Permissions |
|------|---------|-------------|
| `ecs_execution_role` | ECS Agent | ECR pull, CloudWatch logs, Secrets Manager read |
| `ecs_task_role` | Application Container | (ECS Exec), application-specific actions |

**Security:** Trust policies restrict `sts:AssumeRole` to ECS tasks only.

---

### 8. `oidc.tf` — OpenID Connect for GitHub Actions

**Purpose:** Enables passwordless CI/CD from GitHub Actions to AWS.

**How It Works:**
1. GitHub Actions requests OIDC token from GitHub
2. AWS validates token against registered OIDC provider
3. GitHub Actions assumes IAM role temporarily

**Permissions Granted:**
- ECR push/pull (container images)
- ECS service updates (deployments)
- IAM PassRole (for task/execution roles)

**Security Benefit:** No long-lived AWS credentials stored in GitHub secrets.

---

### 9. `ecs.tf` — Elastic Container Service

**Purpose:** Runs and manages containerized application.

**Key Components:**
- **ECS Cluster** — logical grouping of services
- **Task Definition** — Fargate configuration (256 CPU / 512 MB memory)
- **Container Definition** — app image, environment variables, secrets, logging
- **ECS Service** — maintains 2 desired tasks with auto-recovery
- **Auto-scaling** — scales 2-4 tasks based on memory utilization (70%)
- **Deployment Circuit Breaker** — auto-rollback on failed deployments

**Features:**
- `enable_execute_command` — allows `aws ecs exec` for debugging
- `ignore_changes [desired_count]` — prevents Terraform from fighting auto-scaler

---

### 10. `outputs.tf` — Deployment Outputs

**Purpose:** Exposes critical infrastructure information post-deployment.

**Outputs Provided:**
- `alb_dns_name` — Application access URL
- `rds_endpoint` — Database connection string
- `db_secret_arn` — Secrets Manager ARN for credentials
- `ecr_repository_url` — Docker push target
- `ecs_cluster_name` — Cluster identifier
- `vpc_id` / `private_subnet_ids` — Network references

---

## Prerequisites

- **Terraform** >= 1.5.0
- **AWS CLI** configured with appropriate credentials
- **GitHub Repository** (for OIDC integration)
- **Cloudflare DNS** (for HTTPS in production)

---

## Quick Start

### 1. Initialize Terraform
```bash
terraform init
```

### 2. Review Plan
```bash
terraform plan -var-file="terraform.tfvars"
```

### 3. Deploy Infrastructure
```bash
terraform apply -var-file="terraform.tfvars"
```

### 4. Access Application
```bash
# Get ALB DNS from outputs
terraform output alb_dns_name

# Open in browser
open http://$(terraform output -raw alb_dns_name)
```

## Security Highlights

| Layer | Implementation |
|-------|----------------|
| **Network** | Private subnets for compute and database; public only for ALB |
| **Encryption** | RDS storage encrypted; ECR images encrypted |
| **Secrets** | Database passwords in Secrets Manager; injected at runtime |
| **Access Control** | Security group references; no CIDR-based internal trust |
| **CI/CD** | OIDC-based; no long-lived AWS credentials |
| **Least Privilege** | Separate execution and task roles; minimal IAM policies |

---

## Cost Optimization Notes

| Resource | Cost Strategy |
|----------|---------------|
| **NAT Gateway** | Use VPC endpoints to minimize NAT data processing charges |
| **RDS** | Single AZ for dev; Multi-AZ for production |
| **ECS Fargate** | 256 CPU / 512 MB minimum; scale to zero if using Fargate Spot |
| **ALB** | Shared across services; fixed hourly cost regardless of traffic |
| **ECR** | Lifecycle policy limits storage; image scanning on push |

---

## Known Limitations & TODOs

- [ ] **HTTPS:** Currently HTTP only — add ACM certificate and HTTPS listener
- [ ] **NAT Gateway:** Add for private subnet internet access (or verify VPC endpoints cover all needs)
- [ ] **CloudFront:** Add CDN for static assets and DDoS protection
- [ ] **WAF:** Add Web Application Firewall for ALB protection
- [ ] **Route 53:** Add custom domain and health checks
- [ ] **Backup:** Add AWS Backup plan for RDS snapshots
- [ ] **Monitoring:** Add CloudWatch alarms for CPU, memory, and error rates

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| ECS tasks stuck in `PENDING` | Check VPC endpoints, NAT Gateway, or IAM execution role |
| RDS connection refused | Verify security group allows port 5432 from ECS SG |
| ALB health check failing | Ensure `/health` endpoint responds with HTTP 200 |
| GitHub Actions auth failed | Verify OIDC thumbprint and repository name in trust policy |
| Image not updating | Use versioned tags, not `:latest` |

---

## License

MIT License — Demo purposes only. Not for production use without security hardening.

---

## Support

For issues or questions, please open a GitHub issue or contact me.
