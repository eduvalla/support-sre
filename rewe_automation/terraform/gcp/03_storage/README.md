<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_google"></a> [google](#requirement\_google) | ~> 4.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | 4.9.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_naming"></a> [naming](#module\_naming) | ../_modules/naming | n/a |

## Resources

| Name | Type |
|------|------|
| [google_service_account.raw_spans](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account) | resource |
| [google_service_account_key.rawSpansServiceAccountKey](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/service_account_key) | resource |
| [google_storage_bucket.raw_spans](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_member.bucket_creator](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_bucket_iam_member.bucket_reader](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_member) | resource |
| [google_storage_hmac_key.rawSpansHMAC](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_hmac_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The GCP project | `string` | n/a | yes |
| <a name="input_raw_spans_retention_days"></a> [raw\_spans\_retention\_days](#input\_raw\_spans\_retention\_days) | The number of days to keep raw span data in the bucket | `number` | `7` | no |
| <a name="input_region"></a> [region](#input\_region) | The GCP region to create resources in | `string` | n/a | yes |
| <a name="input_zone"></a> [zone](#input\_zone) | The GCP zone to create resources in | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_id"></a> [access\_id](#output\_access\_id) | The access id of the HMAC key for the raw spans bucket |
| <a name="output_raw_spans_bucket"></a> [raw\_spans\_bucket](#output\_raw\_spans\_bucket) | The name of the cloud storage bucket for raws spans |
| <a name="output_secret"></a> [secret](#output\_secret) | The secret of the HMAC key for the raw spans bucket |
<!-- END_TF_DOCS -->