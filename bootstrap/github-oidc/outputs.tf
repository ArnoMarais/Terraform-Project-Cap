output "github_actions_role_arn" {
  description = "Set this as the AWS_ROLE_ARN repository variable in GitHub"
  value       = aws_iam_role.github_actions.arn
}

output "github_actions_role_name" {
  description = "Name of the GitHub Actions IAM role"
  value       = aws_iam_role.github_actions.name
}

output "aws_account_id" {
  description = "AWS account the OIDC role was created in"
  value       = data.aws_caller_identity.current.account_id
}