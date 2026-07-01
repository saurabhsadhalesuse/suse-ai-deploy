# Deployment of SUSE AI Stack on GPU powered instance on GCP

## Environment Prerequisites
Before running Terraform, ensure you have the CLI tools configured for your target cloud. See the instruction to install CLI :- https://docs.cloud.google.com/sdk/docs/install-sdk

```bash
# Install Google Cloud SDK and authenticate
gcloud auth login
gcloud auth application-default login
# Set your active project
gcloud config set project <YOUR_PROJECT_ID>
```

## Running the Terraform Code

1. Copy ./terraform.tfvars.example to ./terraform.tfvars
2. Edit ./terraform.tfvars
  - Update the required variables:
    - `prefix` to give the resources an identifiable name (e.g., your initials or first name)
    - `project_id` to specify in which Project the resources will be created
    - `region` and `zone` to specify the Google region where resources will be created
    - `registry_name` to specify the name of the registry where the SUSE AI stack helm charts are located.
    - `registry_username` to specify the name of the registry username.
    - `registry_password` to specify the password for the registry.
    - `rke2_version` to specify the version of RKE2 cluster to be installed.
3. Then execute the terraform commands:

```bash
# Navigate to the GCP implementation
cd public-clouds/gcp

# Initialize the working directory (downloads providers and modules)
terraform init -upgrade

# Preview the changes (highly recommended)
terraform plan -out=tfplan

# Apply the configuration
terraform apply --auto-approve
```

Default ssh_username to access the instances on cloud is `opensuse` as a custom built OS image is used

## Cleanup:

To tear down the infrastructure and avoid costs:

```bash
terraform destroy
```

## Accessing SUSE AI UI:
Check out the output of `terraform output` and it should have the URL to the SUSE AI UI:

```bash
Outputs:

instance_public_ip = "172.10.10.123"
kubeconfig_path = "/Users/devendrakulkarni/suse-ai-deploy/public-clouds/gcp/kubeconfig-rke2.yaml"
ssh_command = "ssh -i /Users/devendrakulkarni/suse-ai-deploy/public-clouds/gcp/dksuseai-ssh_private_key.pem opensuse@172.10.10.112"
suse_ai_webui_url = "suse-ai.172.10.10.123.sslip.io"
```


