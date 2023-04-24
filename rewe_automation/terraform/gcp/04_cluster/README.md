<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google-beta"></a> [google-beta](#requirement\_google-beta) | ~> 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google-beta"></a> [google-beta](#provider\_google-beta) | 4.9.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | ../_modules/naming | n/a |

## Resources

| Name | Type |
|------|------|
| [google-beta_google_container_cluster.cluster](https://registry.terraform.io/providers/hashicorp/google-beta/latest/docs/resources/google_container_cluster) | resource |
| [terraform_remote_state.networking](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/data-sources/remote_state) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | The Kubernetes version | `string` | `"1.21"` | no |
| <a name="input_node_count"></a> [node\_count](#input\_node\_count) | The number of nodes for the GKE cluster | `string` | `3` | no |
| <a name="input_project"></a> [project](#input\_project) | The GCP project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to create resources in | `string` | n/a | yes |
| <a name="input_state_bucket"></a> [state\_bucket](#input\_state\_bucket) | The name of the bucket for storing Terraform state | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP zone to create resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ca_certificate"></a> [ca\_certificate](#output\_ca\_certificate) | CA certificate (base64-encoded) |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The Kubernetes API server endpoint |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | The gcloud command to get cluster credentials for kubectl |
| <a name="output_location"></a> [location](#output\_location) | The location of the GKE cluster |
| <a name="output_name"></a> [name](#output\_name) | The name of the GKE cluster |
<!-- END_TF_DOCS -->
