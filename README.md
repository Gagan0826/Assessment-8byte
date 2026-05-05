# DevOps Assignment – End-to-End Infrastructure, CI/CD, and Monitoring

## Overview

This project demonstrates an end-to-end DevOps workflow including:

* Infrastructure provisioning using Terraform
* Configuration management using Ansible
* CI/CD automation using GitHub Actions
* Containerized application deployment using Docker
* Monitoring using Prometheus and Grafana
* Logging using AWS CloudWatch

The goal is to showcase ownership across the full lifecycle: **provision → configure → deploy → observe**

---

## Architecture

```
Developer → GitHub → GitHub Actions → AWS ECR → EC2 (Docker) → CloudWatch Logs
                                                     ↓
                                            Prometheus + Grafana
```

### Components

* VPC with public and private subnets
* EC2 instance for application hosting
* ECR for storing Docker images
* (Optional) RDS PostgreSQL
* Prometheus + Grafana for monitoring
* CloudWatch for logging

---

## Tech Stack

* Terraform – Infrastructure as Code
* Ansible – Configuration Management
* Docker – Containerization
* GitHub Actions – CI/CD
* AWS (EC2, VPC, ECR, CloudWatch)
* Prometheus – Metrics collection
* Grafana – Visualization

---

## Repository Structure

```
├── README.md
├── Terrafrom
│   ├── main.tf
│   ├── modules
│   │   ├── EC2
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── ECR
│   │   │   ├── ecr.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   ├── RDS
│   │   │   ├── main.tf
│   │   │   ├── outputs.tf
│   │   │   └── variables.tf
│   │   └── VPC
│   │       ├── main.tf
│   │       ├── outputs.tf
│   │       └── variables.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── versions.tf
├── ansible
│   ├── inventory.ini
│   └── playbook.yml
├── app
│   ├── Dockerfile
│   ├── index.js
│   └── package.json
```

---

## Infrastructure Provisioning

Terraform modules are used to provision:

* VPC with public/private subnets
* EC2 instance with IAM role
* ECR repository
* (Optional) RDS instance

### Run Terraform

```bash
cd Terraform
terraform init
terraform apply
```

---

## Configuration Management (Ansible)

Ansible is used to configure the EC2 instance:

* Install Docker
* Install AWS CLI
* Install CloudWatch Agent
* Configure monitoring

### Run Ansible

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml
```

---

## Application Deployment

* Node.js application containerized using Docker
* Runs on port **3000**, exposed via **port 80** on EC2

### Run manually (for validation)

```bash
docker build -t app ./app
docker run -d -p 80:3000 app
```

---

## CI/CD Pipeline

GitHub Actions pipeline performs:

1. Build Docker image
2. Tag and push image to ECR
3. SSH into EC2
4. Pull latest image
5. Restart container

### Trigger

Pipeline runs on:

```
push → main branch
```

---

## Monitoring (Prometheus + Grafana)

* Node Exporter collects system metrics
* Prometheus scrapes metrics
* Grafana visualizes metrics

### Dashboards

* CPU Usage
* Memory Usage

Access:

```
Grafana → http://<EC2-IP>:3001
Prometheus → http://<EC2-IP>:9090
```

---

## Logging (CloudWatch)

* CloudWatch Agent installed on EC2
* Logs collected:

  * System logs (`/var/log/syslog`)
  * Docker container logs

Accessible via:

```
AWS Console → CloudWatch → Log Groups
```

---

## Security Considerations

* IAM roles used instead of hardcoded credentials
* EC2 uses instance profile for ECR access
* Secrets stored in GitHub Secrets
* Security groups restrict inbound traffic

---

## Challenges Faced

1. Terraform provider version conflicts

   * Fixed by aligning version constraints

2. Docker build path issue

   * Fixed by using correct build context (`./app`)

3. CI/CD SSH failures

   * Resolved by proper key handling and permissions

4. Port mismatch (3000 vs 80)

   * Fixed using correct Docker port mapping

5. Ansible execution via Terraform

   * Failed due to SSH prompt and timing issues
   * Resolved by disabling host key checking and decoupling execution

6. CloudWatch logs not appearing

   * Fixed by attaching correct IAM policy

---

## Improvements

* Use Auto Scaling Group instead of single EC2
* Replace SSH deployment with ECS/EKS
* Use Terraform remote backend (S3 + DynamoDB)
* Add alerting in Prometheus
* Use HTTPS with ALB

---

## How to Validate

1. Open application:

```
http://<EC2-IP>
```

2. Check CI/CD:

* GitHub → Actions → successful run

3. Check monitoring:

* Grafana dashboards visible

4. Check logs:

* CloudWatch log groups populated

---

## Conclusion

This project demonstrates a complete DevOps workflow with:

* Infrastructure provisioning
* Automated deployment
* Observability
* Secure and modular design

---
