# Parts from: https://gitlab.com/guided-explorations/aws/configure-openid-connect-in-aws

# Extra IAM permissions required: "iam:CreateOpenIDConnectProvider", "iam:DeleteOpenIDConnectProvider", "iam:GetOpenIDConnectProvider", "iam:TagOpenIDConnectProvider", "iam:UpdateOpenIDConnectProviderThumbprint"

data "tls_certificate" "this" {
  url = var.idp_tls_url
}

locals {
  idp_thumbprints = data.tls_certificate.this.certificates[*].sha1_fingerprint
}

resource "aws_iam_openid_connect_provider" "this" {
  url            = var.idp_url
  client_id_list = [var.client_id]

  # We can add up to 5 thumbprints but AWS seems to have stopped using them for server certificate verification
  thumbprint_list = length(local.idp_thumbprints) <= 5 ? local.idp_thumbprints : slice(local.idp_thumbprints, 1, 6)

  tags = merge(
    var.tags,
    { "Name" : var.name }
  )
}

data "aws_iam_policy_document" "this" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.this.arn]
    }
    condition {
      test     = "StringLike"
      variable = "${aws_iam_openid_connect_provider.this.url}:sub"
      values   = var.subjects
    }
  }
}

# Be wary of granting the OIDC role additional permissions to perform specific deployment jobs: use a deployment role instead
resource "aws_iam_policy" "this" {
  name = var.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "sts:AssumeRole"
        Effect   = "Allow"
        Resource = var.deploy_role_arns
      },
    ]
  })

  tags = merge(
    var.tags,
    { "Name" : var.name }
  )
}

resource "aws_iam_role" "this" {
  name        = var.name
  description = var.description

  assume_role_policy    = data.aws_iam_policy_document.this.json
  permissions_boundary  = var.permissions_boundary_arn
  force_detach_policies = var.force_detach_policies

  tags = merge(
    var.tags,
    { "Name" : var.name }
  )
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
