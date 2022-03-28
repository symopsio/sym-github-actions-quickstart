locals {
  resolved_secret_path = var.secret_path != "" ? var.secret_path : "/symops.com/${var.runtime_name}"
  secrets_tags         = merge({ "SymEnv" = var.runtime_name }, var.tags)
}

# Creates an AWS Secrets Manager secret that can store shared secrets
resource "aws_secretsmanager_secret" "this" {
  name        = local.resolved_secret_path
  description = "Shared secrets for Sym Integrations in Runtime: ${var.runtime_name}"

  tags = local.secrets_tags
}

# Secrets storage that Sym integrations can refer to
resource "sym_secrets" "this" {
  type = "aws_secrets_manager"
  name = var.runtime_name

  settings = {
    context_id = sym_integration.runtime_context.id
  }
}

