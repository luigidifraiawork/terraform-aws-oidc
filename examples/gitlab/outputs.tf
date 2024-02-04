output "oidc_role_arn" {
  description = "ARN of the role that must be assumed by the GitLab Runner"
  value       = module.gitlab.role_arn
}

output "deploy_role_arn" {
  description = "ARN of the role that must be assumed by the OIDC role for deployment purposes"
  value       = aws_iam_role.deploy.arn
}
