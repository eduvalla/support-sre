<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.9.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming_dns"></a> [naming\_dns](#module\_naming\_dns) | ../_modules/naming | n/a |

## Resources

| Name | Type |
|------|------|
| [google_project_iam_custom_role.dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_custom_role) | resource |
| [google_project_iam_member.cert_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_project_iam_member.external_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_iam_member) | resource |
| [google_service_account.dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_iam_member.cert_manager](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |
| [google_service_account_iam_member.external_dns](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_iam_member) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The GCP project | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to create resources in | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP zone to create resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_access_service_account"></a> [dns\_access\_service\_account](#output\_dns\_access\_service\_account) | The service account with permissions to manage DNS records |
<!-- END_TF_DOCS -->