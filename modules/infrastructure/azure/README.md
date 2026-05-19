# Azure Infrastructure Module for SUSE AI

This module provisions a GPU-accelerated instance running **openSUSE Leap** and prepares it for the SUSE AI stack by installing NVIDIA drivers and RKE2.

## Features
* Provisions **Standard_NC4as_T4_v3** instance types with NVIDIA GPUs.
* Uses **openSUSE Leap 15.x** AMI.
* Automated driver installation via `startupscript.tftpl`.
* Configures Security Groups for SSH and Kubernetes API (6443).

In order for Terraform to run operations on your behalf, you must [install and configure the Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli).

#### macOS installation and setup

```bash
brew update && brew install azure-cli
```

```bash
az login
```

##### If there are other active subscriptions, run

```bash
az account set --subscription `SUBSCRIPTION_ID`
```

## Usage

```hcl
module "azure_gpu_node" {
  source        = "../../modules/infrastructure/azure"

  prefix        = "suse-ai-dev"
  instance_type = "Standard_NC4as_T4_v3"   
  vpc_id        = "vpc-12345"
  subnet_id     = "subnet-12345"

}
```
