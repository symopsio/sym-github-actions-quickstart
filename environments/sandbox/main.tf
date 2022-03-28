provider "aws" {
  region = var.aws_region
}

provider "sym" {
  org = var.sym_org_slug
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
