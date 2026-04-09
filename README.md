# SUSE AI Deployment on Public Clouds:

This repository contains Terraform configurations to deploy complete SUSE AI stack on GPU-enabled infrastructure on public clouds [AWS/Azure/GCP]. It automates the provisioning of cloud resources and the deployment of essential AI components.

## 🏗 Architecture Overview

<img width="1536" height="1024" alt="ChatGPT Image Apr 9, 2026, 04_00_50 PM" src="https://github.com/user-attachments/assets/e91b6981-d035-4125-a7c7-4caf76682e94" />

The project is split into two main sections:

- **Modules**: Reusable components for Cloud Infrastructure (AWS/GCP) and Kubernetes applications.
- **Public Clouds**: Root modules that orchestrate the deployment by calling the infrastructure and kubernetes modules.

### Components Deployed

* **Infrastructure**: GPU-optimized instances running openSUSE.
* **Stack**: RKE2 (via startup scripts), NVIDIA GPU Operator, Ollama, Milvus, Open WebUI, and Cert-Manager.

---

## 🚀 Quick Start

### 1. Prepare Variables

Each environment requires a `terraform.tfvars` file. Copy the provided examples:

For AWS:

```bash
cp public-clouds/aws/terraform.tfvars.example public-clouds/aws/terraform.tfvars
```

For GCP:

```bash
cp public-clouds/gcp/terraform.tfvars.example public-clouds/gcp/terraform.tfvars
```

For Azure:

```bash
cp public-clouds/azure/terraform.tfvars.example public-clouds/azure/terraform.tfvars
```

### 2. Deployment

Deployment on AWS:

```bash
cd public-clouds/aws
terraform init -upgrade
terraform apply
```

Deployment on GCP:

```bash
cd public-clouds/gcp
terraform init -upgrade
terraform apply
```

Deployment on Azure:

```bash
cd public-clouds/azure
terraform init -upgrade
terraform apply
```

---

## Directory Structure:

- `modules/infrastructure`: Cloud-specific VM and networking logic.

- `modules/kubernetes`: Helm releases and K8s manifests for the AI stack.

- `public-clouds/`: Entry points for deployment.

---

## Cleanup:

To tear down the infrastructure and avoid costs:

```bash
terraform state rm module.kubernetes && terraform destroy --auto-approve 
```
