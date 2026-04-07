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

## Cleanup:

To tear down the infrastructure and avoid costs:

```bash
terraform destroy
```

## Accessing SUSE AI WebUI on browser:

To access SUSE AI WebUi on your browser, you need to map the public IP of the instance to `suse-ollama-webui` host in `/etc/hosts`:

```bash
vi /etc/hosts

<public-ip-of-instance>  suse-ollama-webui
```


