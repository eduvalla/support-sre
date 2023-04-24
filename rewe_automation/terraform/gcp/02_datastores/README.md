<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | ../_modules/naming | n/a |

## Resources

| Name | Type |
|------|------|
| [google_compute_instance.single](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance) | resource |
| [google_service_account.registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket_iam_member.registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket.registry](https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/storage_bucket) | data source |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_agent_key_db"></a> [agent\_key\_db](#input\_agent\_key\_db) | The agent key for the data store host | `string` | n/a | yes |
| <a name="input_base_domain"></a> [base\_domain](#input\_base\_domain) | The base domain | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_installer_version"></a> [installer\_version](#input\_installer\_version) | The version of the Docker-based installer. Use '*' for the latest version | `string` | `"*"` | no |
| <a name="input_instana_registry"></a> [instana\_registry](#input\_instana\_registry) | The Docker registry to pull images from | `string` | `"containers.instana.io"` | no |
| <a name="input_project"></a> [project](#input\_project) | The GCP project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to create resources in | `string` | n/a | yes |
| <a name="input_rpm_repo_url"></a> [rpm\_repo\_url](#input\_rpm\_repo\_url) | The URL of the RPM repository | `string` | `"https://instana-onprem-installer-internal.s3.amazonaws.com"` | no |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | The name of the bucket for storing Terraform state | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP zone to create resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_datastores_ip"></a> [datastores\_ip](#output\_datastores\_ip) | The IP address of the datastores host |
<!-- END_TF_DOCS -->
