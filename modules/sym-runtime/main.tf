# Creates an AWS IAM Role that a Sym runtime can use for execution
module "runtime_connector" {
  source  = "terraform.symops.com/symopsio/runtime-connector/sym"
  version = ">= 1.1.0"

  addons          = ["aws/secretsmgr"]
  environment     = var.runtime_name
  sym_account_ids = var.sym_account_ids

  tags = var.tags
}

# The base permissions that a workflow has access to
resource "sym_integration" "runtime_context" {
  type = "permission_context"
  name = "runtime-${var.runtime_name}"

  external_id = module.runtime_connector.settings.account_id
  settings    = module.runtime_connector.settings
}

# Declares a runtime where workflows can execute
resource "sym_runtime" "this" {
  name       = var.runtime_name
  context_id = sym_integration.runtime_context.id
}

# An integration with Slack
resource "sym_integration" "slack" {
  type = "slack"
  name = var.runtime_name

  external_id = var.slack_workspace_id
}

