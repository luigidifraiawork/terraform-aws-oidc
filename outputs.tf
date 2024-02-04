output "role_arn" {
  description = "Role that must be assumed by the client"
  value       = aws_iam_role.this.arn
}
