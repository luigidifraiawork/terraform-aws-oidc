# Configure OpenID Connect in AWS to retrieve temporary credentials and access services in AWS

Parts from: https://gitlab.com/guided-explorations/aws/configure-openid-connect-in-aws

## Use-cases
- Retrieve temporary credentials from AWS to access cloud services

## Examples
- [GitLab](https://github.com/luigidifraiawork/terraform-aws-oidc/tree/main/examples/gitlab) - Creates an IAM identity provider for GitLab OIDC, an IAM role that trusts the IAM GitLab OIDC provider, and an IAM role for deployment purposes that trusts the latter.  

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_openid_connect_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_openid_connect_provider) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [tls_certificate.this](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/data-sources/certificate) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_client_id"></a> [client\_id](#input\_client\_id) | This is the value that's sent as the client\_id parameter on OAuth requests | `string` | n/a | yes |
| <a name="input_deploy_role_arns"></a> [deploy\_role\_arns](#input\_deploy\_role\_arns) | ARNs of the roles the OIDC role can assume for deployment purposes | `list(string)` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | OIDC role description | `string` | `null` | no |
| <a name="input_force_detach_policies"></a> [force\_detach\_policies](#input\_force\_detach\_policies) | Whether policies should be detached from the OIDC role when destroying | `bool` | `true` | no |
| <a name="input_idp_tls_url"></a> [idp\_tls\_url](#input\_idp\_tls\_url) | The TLS URL of the identity provider | `string` | n/a | yes |
| <a name="input_idp_url"></a> [idp\_url](#input\_idp\_url) | The URL of the identity provider. Corresponds to the iss claim | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Name to be used on all the resources as identifier | `string` | n/a | yes |
| <a name="input_permissions_boundary_arn"></a> [permissions\_boundary\_arn](#input\_permissions\_boundary\_arn) | Permissions boundary ARN to use for the OIDC role | `string` | `null` | no |
| <a name="input_subjects"></a> [subjects](#input\_subjects) | List of OIDC subjects that are permitted by the trust policy | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of additional tags to add to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | Role that must be assumed by the client |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References
- https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_oidc.html
