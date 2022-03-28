provider "aws" {
  region = var.aws_region
}

resource "aws_iam_openid_connect_provider" "this" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html
  thumbprint_list = [
    "a031c46782e6e6c662c2c87c76da9aa62ccabd8e",
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]
}

resource "aws_iam_role" "this" {
  name        = var.role_name
  path        = "/sym/"
  description = "Access to deploy Sym from GitHub actions"

  assume_role_policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "${aws_iam_openid_connect_provider.this.arn}"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:${var.github_org}/${var.github_repo}:*"
                }
            }
        }
    ]
}
  EOT
}

resource "aws_iam_role_policy_attachment" "sym" {
  policy_arn = aws_iam_policy.sym_provision_policy.arn
  role       = var.role_name
}

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "sym_provision_policy" {
  name        = var.role_name
  path        = "/sym/"
  description = "Access to run Sym GitHub actions"

  policy = templatefile("${path.module}/policy.json", {
    aws_account_id = data.aws_caller_identity.current.account_id
  })
}
