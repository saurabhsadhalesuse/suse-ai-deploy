# Deployment of SUSE AI Stack on GPU powered instance on Azure

## Environment Prerequisites
Before running Terraform, ensure you have the Azure CLI configured for your target subscription. See the instruction to install CLI https://learn.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest

```bash
# Log in to your Azure account
az login

# Set your active subscription if you have multiple
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

## Running the Terraform Code
- Copy ./terraform.tfvars.example to ./terraform.tfvars

- Edit ./terraform.tfvars

##Update the required variables:

- `prefix` to give the resources an identifiable name (e.g., your initials or first name)

- `location` to specify the Azure region where resources will be created (e.g., eastus)

- `subscription_id` to specify the Azure subscription used for billing

- `registry_name` to specify the name of the registry where the SUSE AI stack helm charts are located.

- `registry_username` to specify the name of the registry username.

- `registry_password` to specify the password for the registry.

- `rke2_version` to specify the version of RKE2 cluster to be installed.

## Then execute the terraform commands:

```bash
# Navigate to the Azure implementation
cd public-clouds/azure

# Initialize the working directory (downloads providers and modules)
terraform init -upgrade

# Preview the changes (highly recommended)
terraform plan -out=tfplan

# Apply the configuration
terraform apply "tfplan"

# Apply the configuration
terraform apply --auto-approve
```

Default ssh_username to access the instances on cloud is `opensuse` as a custom built OS image is used

## Cleanup:
To tear down the infrastructure and avoid costs:

```bash
terraform destroy --auto-approve
```

## Accessing SUSE AI UI:
Check out the output of `terraform output` and it should have the URL to the SUSE AI UI:

```bash
Outputs:

instance_public_ip = "172.10.10.123"
kubeconfig_path = "/Users/devendrakulkarni/suse-ai-deploy/public-clouds/azure/kubeconfig-rke2.yaml"
ssh_command = "ssh -i /Users/devendrakulkarni/suse-ai-deploy/public-clouds/azure/dksuseai-ssh_private_key.pem opensuse@172.10.10.112"
suse_ai_webui_url = "suse-ai.172.10.10.123.sslip.io"
```
