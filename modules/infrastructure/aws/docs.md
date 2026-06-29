## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.100.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.8.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ami.opensuse_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami) | resource |
| [aws_ebs_snapshot_import.opensuse_snapshot](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot_import) | resource |
| [aws_iam_instance_profile.ssm_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ssm_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.vmimport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vmimport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.ssm_attach](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.opensuse_gpu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.default_igw](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.generated_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.default_rt](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.public_assoc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_s3_bucket.images](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_object.vhd](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.default_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.default_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [local_file.private_key_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [null_resource.download_certified_vhd](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.retrieve_kubeconfig](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.rke2_installation](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.wait_for_gpu](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [tls_private_key.ssh_private_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.opensuse_leap](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_associate_public_ip"></a> [associate\_public\_ip](#input\_associate\_public\_ip) | Set to true if using a public subnet, false for private. | `bool` | `true` | no |
| <a name="input_certified_os_image"></a> [certified\_os\_image](#input\_certified\_os\_image) | Specifies whether to use the SUSE AI DEPLOY OS image released in the GitHub repository. If set to false, the default OpenSUSE image provided by the cloud provider will be used. Default is 'false'. | `bool` | `false` | no |
| <a name="input_certified_os_image_tag"></a> [certified\_os\_image\_tag](#input\_certified\_os\_image\_tag) | Specifies which GitHub release to use for the OpenSUSE image. Default is 'build-1'. | `string` | `"build-1"` | no |
| <a name="input_create_ssh_key_pair"></a> [create\_ssh\_key\_pair](#input\_create\_ssh\_key\_pair) | Whether to generate a new SSH key pair | `bool` | `true` | no |
| <a name="input_existing_key_name"></a> [existing\_key\_name](#input\_existing\_key\_name) | n/a | `string` | `null` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | Instance type for the VM (must support GPUs, e.g., g4dn.xlarge) | `string` | `"g4dn.xlarge"` | no |
| <a name="input_ip_cidr_range"></a> [ip\_cidr\_range](#input\_ip\_cidr\_range) | The IP range for the subnet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_os_disk_size"></a> [os\_disk\_size](#input\_os\_disk\_size) | Size of the root OS disk in GB | `number` | `150` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources to ensure uniqueness | `string` | `"aws-tf"` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region to deploy into | `string` | `"us-west-2"` | no |
| <a name="input_rke2_version"></a> [rke2\_version](#input\_rke2\_version) | The version of RKE2 to install | `string` | `"v1.30.2+rke2r1"` | no |
| <a name="input_ssh_private_key_path"></a> [ssh\_private\_key\_path](#input\_ssh\_private\_key\_path) | Path to save/read the private key (null for default naming) | `string` | `null` | no |
| <a name="input_ssh_public_key_path"></a> [ssh\_public\_key\_path](#input\_ssh\_public\_key\_path) | Path to save/read the public key (null for default naming) | `string` | `null` | no |
| <a name="input_subnet_id"></a> [subnet\_id](#input\_subnet\_id) | Existing Subnet ID (leave null if creating a new subnet) | `string` | `null` | no |
| <a name="input_use_existing_vpc"></a> [use\_existing\_vpc](#input\_use\_existing\_vpc) | n/a | `bool` | `false` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | Existing VPC ID (leave null if creating a new VPC) | `string` | `null` | no |
| <a name="input_zone"></a> [zone](#input\_zone) | Availability zone for the instance and EBS volume | `string` | `"us-west-2a"` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_instance_public_ip"></a> [instance\_public\_ip](#output\_instance\_public\_ip) | n/a |
| <a name="output_kubeconfig_done"></a> [kubeconfig\_done](#output\_kubeconfig\_done) | n/a |
| <a name="output_kubeconfig_path"></a> [kubeconfig\_path](#output\_kubeconfig\_path) | n/a |
| <a name="output_ssh_command"></a> [ssh\_command](#output\_ssh\_command) | Convenience command to login |
| <a name="output_ssh_private_key_content"></a> [ssh\_private\_key\_content](#output\_ssh\_private\_key\_content) | The content of the generated private key |
