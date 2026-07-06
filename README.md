# SUSE AI Deployment on Public Clouds:

### ⚠️ SUSE AI Deploy is currently an unofficial, community-maintained project and is not officially supported by SUSE.

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

### Generate your AppCo Access token:

* Login to https://apps.rancher.io
* Once logged in, click on your profile avatar and click on `Settings`:
<img width="2048" height="794" alt="Profile-Avatar" src="https://github.com/user-attachments/assets/e3a38c9d-5b3a-44e1-81b5-6c86afa5ef95" />

* In your profile settings, verify if you have the SUSE AI entitlement:
<img width="2048" height="882" alt="VerifySUSEAISubscription" src="https://github.com/user-attachments/assets/16ea6ebb-a5de-47a0-8423-615765003d01" />

* Then, click on `Access Tokens`:
<img width="2048" height="882" alt="Access Token" src="https://github.com/user-attachments/assets/c020ff26-e189-4f27-b5df-eaf878843c76" />

* Add description and click on `Create Token`:
<img width="2048" height="882" alt="Create Token" src="https://github.com/user-attachments/assets/73129aa8-3317-436b-acb4-8590d4e64cfb" />

* Your token should be displayed as following:
<img width="2048" height="882" alt="Screenshot 2026-04-09 at 8 13 13 PM" src="https://github.com/user-attachments/assets/39b85406-2b3f-4eca-b42c-65de4bdb1952" />

This will provide you the required values for variables `registry_name`, `registry_username` and `registry_password`:
* `registry_name` would be `dp.apps.rancher.io`
* `registry_username` would be your email id OR the value you see in the above screenshot after `-u` option in the docker, helm, kubernetes and curl command.
* `registry_password` would be the value you see after `-p` option in the docker, helm and kubernetes command. For curl, its after the delimeter `:` after option `-u`.


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
