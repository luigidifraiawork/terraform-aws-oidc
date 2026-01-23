# Configure OpenID Connect in AWS for a GitLab CI/CD job to retrieve temporary credentials and access services in AWS

The Terraform manifests provided in this folder create an IAM identity provider for GitLab OIDC, an IAM role that trusts the IAM GitLab OIDC provider, and an IAM role for deployment purposes that trusts the latter. In fact, the OIDC role is used as a jump role that can assume further roles with limited permissions for their specific deployment requirements.

## Usage

To run this example you need to execute:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

Note that this example may create resources that cost money. Run `terraform destroy` when you don't need these resources.

## GitLab CI/CD pipeline configuration

After you create the OIDC provider and relevant roles, a GitLab CI/CD job can retrieve a temporary credential from the AWS Security Token Service (STS). The OIDC role can then assume the deployment role which can finally create ECR repositories and push Docker images to them.

As an example, for an Alpine Linux-based GitLab Runner you might have something like the below in _.gitlab-ci.yml_:

```yaml
# Assume the Gitlab OIDC role and then the deployment role 
.assume_role:
  script:
    - apk add --no-cache alpine-sdk gcc python3-dev py-pip jq
    - pip install awscli
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role-with-web-identity
      --role-arn ${OIDC_ROLE_ARN}
      --role-session-name "gitlab-oidc-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --web-identity-token ${GITLAB_OIDC_TOKEN}
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))
    - >
      export $(printf "AWS_ACCESS_KEY_ID=%s AWS_SECRET_ACCESS_KEY=%s AWS_SESSION_TOKEN=%s"
      $(aws sts assume-role
      --role-arn ${DEPLOY_ROLE_ARN}
      --role-session-name "gitlab-deploy-${CI_PROJECT_ID}-${CI_PIPELINE_ID}"
      --duration-seconds 3600
      --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]'
      --output text))

deploy_job:
  id_tokens:
    GITLAB_OIDC_TOKEN:
      aud: https://gitlab.com
  before_script:
    - !reference [.assume_role, script]
  script:
    - aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
    - docker push ${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${CI_PROJECT_NAME}:${CI_COMMIT_REF_SLUG}-${CI_COMMIT_SHORT_SHA}
  only:
    - main
```

Where:
- `OIDC_ROLE_ARN` is set to the Terraform output `oidc_role_arn`
- `DEPLOY_ROLE_ARN` is set to the Terraform output `deploy_role_arn`

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

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_gitlab"></a> [gitlab](#module\_gitlab) | ../.. | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.deploy_ecr](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.deploy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deploy_role_arn"></a> [deploy\_role\_arn](#output\_deploy\_role\_arn) | ARN of the role that must be assumed by the OIDC role for deployment purposes |
| <a name="output_oidc_role_arn"></a> [oidc\_role\_arn](#output\_oidc\_role\_arn) | ARN of the role that must be assumed by the GitLab Runner |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## References:
- https://docs.gitlab.com/ee/ci/cloud_services/aws/
