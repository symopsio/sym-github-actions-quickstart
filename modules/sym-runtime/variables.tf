variable "error_channel" {
  description = "The error channel to use to surface Sym errors."
  type        = string
  default     = "#sym-errors"
}

variable "runtime_name" {
  description = "Name to assign to the Sym Runtime and its associated resources."
  type        = string
}

variable "secret_path" {
  description = "The path to the AWS Secrets Manager secret to create for shared secrets. If unspecified, the default path is '/symops.com/$${var.runtime_name}'."
  type        = string
  default     = ""
}

variable "slack_workspace_id" {
  description = "The Slack Workspace ID to use for your Slack integration."
  type        = string
}

variable "sym_account_ids" {
  description = "List of account ids that can assume the Sym runtime role. By default, only Sym production accounts can assume the runtime role."
  type        = list(string)
  default     = ["803477428605"]
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
