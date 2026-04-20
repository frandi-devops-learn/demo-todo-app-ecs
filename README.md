AWS Private ECS Infrastructure (UAT Environment)
This repository contains the Infrastructure as Code (IaC) required to deploy a secure, containerized backend on AWS. The architecture is designed for a UAT (User Acceptance Testing) environment, prioritizing security, cost-efficiency, and automation.

🚀 Why Terraform for IaC?
We use Terraform to manage this infrastructure for several key reasons:

Consistency: Eliminates "configuration drift." The environment can be destroyed and rebuilt exactly the same way every time.

Version Control: Our infrastructure is documented in code, allowing us to track changes, peer-review updates, and roll back if necessary.

Speed: Provisioning a complex VPC with RDS and ECS manually takes hours; Terraform does it in minutes.

Documentation: The code itself serves as the documentation for how the network and security layers are connected.