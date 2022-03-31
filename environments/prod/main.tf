provider "aws" {
  region = var.aws_region
}

provider "sym" {
  org = var.sym_org_slug
}

data "aws_caller_identity" "current" {}

module "remote_state" {
  source  = "cloudposse/tfstate-backend/aws"
  version = "= 0.38.1"

  namespace  = "sym"
  name       = "tfstate"
  attributes = [data.aws_caller_identity.current.account_id]

  terraform_backend_config_file_path = "."
  terraform_backend_config_file_name = "backend.tf"
  terraform_state_file               = "prod/terraform.tfstate"
  force_destroy                      = false
}

# A Sym Runtime that executes your Flows.
module "sym_runtime" {
  source = "../../modules/sym-runtime"

  error_channel      = var.error_channel
  runtime_name       = var.runtime_name
  slack_workspace_id = var.slack_workspace_id
  sym_account_ids    = var.sym_account_ids
  tags               = var.tags
}

# A Flow that can manage access to a list of Okta target groups.
module "okta_access_flow" {
  source = "../../modules/okta-access-flow"

  flow_vars        = var.flow_vars
  okta_org_domain  = var.okta_org_domain
  secrets_settings = module.sym_runtime.secrets_settings
  sym_environment  = module.sym_runtime.environment
  targets          = var.okta_targets
}
