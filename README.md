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
* RDS PostgreSQL in private subnets
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
│   │   │   ├── main.tf
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
* RDS PostgreSQL instance

### Run Terraform

```bash
cd Terrafrom
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
* IAM role includes CloudWatch Agent policy

Accessible via:

```
AWS Console → CloudWatch → Log Groups
```

### CloudWatch Metrics (Host-Level)

CloudWatch Agent is also configured to publish EC2 host-level metrics to CloudWatch.

**Namespace:** `DevOpsApp`

**Collected metrics (60s interval):**
- CPU: `cpu_usage_idle`
- Memory: `mem_used_percent`

We use this together with Prometheus + Grafana:
- Prometheus/Grafana provide rich dashboards and detailed metric exploration.
- CloudWatch provides AWS-native monitoring and alarm integration.
- Together, they improve operational visibility and incident response.

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
   * Resolved by disabling host key checking and waiting for EC2 SSH readiness

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

## Architectural Decisions

### 1. Modular Terraform Design
Terraform modules were used for VPC, EC2, ECR, and RDS.

**reason:**
- Improves reusability and separation of concerns  
- Makes infrastructure easier to maintain and scale  

---

### 2. EC2-based Deployment (instead of ECS/EKS)
The application is deployed on a single EC2 instance.

**reason:**
- Simpler setup within time constraints  
- Suitable for demonstrating end-to-end DevOps workflow  
- Easier debugging and control  

---

### 3. Docker for Application Packaging
The application is containerized using Docker.

**reason:**
- Ensures consistent runtime environment  
- Simplifies deployment across environments  
- Required for CI/CD pipeline  

---

### 4. ECR as Container Registry
AWS ECR is used to store Docker images.

**reason:**
- Native AWS integration  
- Secure access via IAM roles  
- Avoids external dependencies  

---

### 5. GitHub Actions for CI/CD
Pipeline automates build, push, and deployment.

**reason:**
- Simple integration with GitHub  
- No additional infrastructure required  
- Supports automated deployment on code changes  

---

### 6. Ansible for Configuration Management
Ansible is used to configure EC2 after provisioning.

**reason:**
- Separates infrastructure from configuration  
- Ensures idempotent setup  
- Easier to extend for future configurations  

---

### 7. Monitoring with Prometheus + Grafana
Prometheus collects metrics, Grafana visualizes them.

**reason:**
- Open-source and widely used  
- Provides detailed system-level visibility  
- Complements CloudWatch  

---

### 8. CloudWatch for Logging
CloudWatch Agent is installed and used for EC2 observability with IAM-based access.

**reason:**
- Native AWS service  
- No additional setup overhead  
- Easy integration with AWS monitoring and alarms  

---

### 9. IAM Roles Instead of Static Credentials
EC2 uses IAM instance profile.

**reason:**
- Avoids hardcoding secrets  
- Follows AWS security best practices  

## Security Considerations

### 1. IAM Roles for EC2
EC2 instance uses IAM role to access ECR and CloudWatch.

**Benefit:**
- No credentials stored on instance  
- Reduces risk of credential leakage  

---

### 2. GitHub Secrets for Sensitive Data
AWS credentials and SSH keys stored in GitHub Secrets.

**Benefit:**
- Prevents exposure in codebase  
- Secure injection into CI/CD pipeline  

---

### 3. Network Security (Security Groups)
Only required ports are opened:

- 22 (SSH)
- 80 (Application)
- 3001 (Grafana)
- 9090 (Prometheus)

**Improvement:**
- SSH should be restricted to specific IP ranges  

---

### 4. Private Subnets for Sensitive Resources
RDS deployed in private subnet.

**Benefit:**
- Not exposed to public internet  
- Improved data security  

**Current Terraform note:**
- RDS is in private subnets, but the RDS security group currently allows `5432` from `0.0.0.0/0`; restrict this before production use.

---

### 5. Container Isolation
Application runs inside Docker container.

**Benefit:**
- Isolates application from host system  
- Reduces impact of vulnerabilities  

---

### 6. No Hardcoded Secrets
All credentials handled via:
- IAM roles  
- GitHub Secrets  

---

### 7. Principle of Least Privilege
IAM policies are limited to:
- ECR read access  
- CloudWatch logging  

---

### 8. Known Limitations 

- SSH access is open (0.0.0.0/0) for demo purposes  
- HTTPS is not configured  
- No WAF or ALB  

### 9. Public Exposure of Monitoring Endpoints

Grafana (port 3001) and Prometheus (port 9090) are currently exposed to the public internet.

**Risks:**
- Unauthorized access to infrastructure metrics  
- Potential information leakage about system performance
- Exposure to brute-force attacks (especially Grafana login)

**Reason (for this setup):**
- Enables easy access for evaluation and demonstration  
- Reduces complexity during initial setup  

**Recommended Improvements:**
- Restrict access using Security Groups (allow only specific IP ranges)  
- Use HTTPS via an Application Load Balancer (ALB)  
- Integrate authentication (OAuth / SSO) for Grafana  

**Current Status:**
Monitoring endpoints are publicly accessible for demonstration purposes only and should be secured before production deployment.