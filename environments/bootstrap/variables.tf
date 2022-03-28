variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "github_org" {
  description = "GitHub org for the repo with the action that will use this IAM role"
  type        = string
  default     = "sym-collab"
}

variable "github_repo" {
  description = "GitHub repo with the action that will use this IAM role"
  type        = string
  default     = "sym-github-actions-quickstart"
}

variable "role_name" {
  description = "Name to assign to the IAM Role and Policy that the GitHub action will use"
  type        = string
  default     = "SymGitHubActionsAccess"
}
