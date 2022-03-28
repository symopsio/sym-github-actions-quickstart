variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "error_channel" {
  description = "The error channel to use to surface Sym errors."
  type        = string
}

variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python"
  type        = map(string)
  default     = {}
}

variable "okta_org_domain" {
  description = "Domain of the Okta account to use for this Flow. Example: 'my-org.okta.com'"
  type        = string
}

variable "okta_targets" {
  description = "List of Okta targets that end-users can request access to. Each object has a label and a group_id."
  type = list(object(
    { label = string, group_id = string }
  ))
}

variable "runtime_name" {
  description = "Name to assign to the Sym Runtime and its associated resources."
  type        = string
}

variable "slack_workspace_id" {
  description = "The Slack Workspace ID to use for your Slack integration"
  type        = string
}

variable "sym_account_ids" {
  description = "List of account ids that can assume the Sym runtime role. By default, only Sym production accounts can assume the runtime role."
  type        = list(string)
  default     = ["803477428605"]
}

variable "sym_org_slug" {
  description = "Sym org slug for your org"
  type        = string
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
