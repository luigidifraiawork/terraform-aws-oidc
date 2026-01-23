# Reference: https://docs.gitlab.com/ee/ci/cloud_services/aws/

provider "aws" {
  region = local.region

  default_tags {
    tags = local.tags
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  # Name prefix to be used on all the resources as identifier
  name = "ex-${basename(path.cwd)}"

  region = "eu-west-2"

  # Name of the role assumed by the OIDC role for deployment purposes
  deploy_role_name = "${local.name}-deploy"

  account_id = data.aws_caller_identity.current.account_id
  partition  = data.aws_partition.current.partition

  tags = {
    CreatedBy  = "Terraform"
    GithubRepo = "terraform-aws-oidc"
    GithubOrg  = "luigidifraiawork"
  }
}

data "aws_iam_policy_document" "deploy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:${local.partition}:iam::${local.account_id}:root"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:PrincipalArn"
      values   = [module.gitlab.role_arn]
    }
  }
}

resource "aws_iam_policy" "deploy_ecr" {
  name = "${local.name}-deploy-ecr"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage",
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })

  tags = { "Name" : "${local.name}-deploy-ecr" }
}

# It is preferable to use the OIDC role as a jump role that can assume further roles with limited permissions for their specific deployment requirements
resource "aws_iam_role" "deploy" {
  name        = local.deploy_role_name
  description = "Role with limited permissions assumed by the OIDC role for deployment purposes"

  assume_role_policy = data.aws_iam_policy_document.deploy.json

  tags = { "Name" : local.deploy_role_name }
}

resource "aws_iam_role_policy_attachment" "deploy" {
  role       = aws_iam_role.deploy.name
  policy_arn = aws_iam_policy.deploy_ecr.arn
}

module "gitlab" {
  source = "../.."

  name        = local.name
  description = "OIDC role to limit authorization to a specific GitLab group, project, branch, or tag"

  idp_tls_url = "tls://gitlab.com:443"
  idp_url     = "https://gitlab.com"
  client_id   = "https://gitlab.com"
  subjects    = ["project_path:mygroup/myprojectgroup/*:ref_type:branch:ref:main"]

  # Prevent a resource cycle
  deploy_role_arns = ["arn:${local.partition}:iam::${local.account_id}:role/${local.deploy_role_name}"]
  #deploy_role_arns = [aws_iam_role.deploy.arn]
}
