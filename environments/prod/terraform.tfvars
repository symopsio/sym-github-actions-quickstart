aws_region = "us-east-1"

# Slack Channel to send integration or runtime errors to
error_channel = "#sym-errors"

flow_vars = {
  request_channel = "#sym-requests" # Slack Channel where requests should go

  approver_group = "CHANGEME" # Optional Okta group to enable approvers authz
}

# Domain of the Okta account to use for Sym integrations
okta_org_domain = "CHANGEME"

# List of targets that users can request Okta access to.
# Each item has a label and group id.
okta_targets = [
  {
    label    = "AWS Ops Admin",
    group_id = "CHANGEME" # Okta Group ID
  }
]

# Name to assign to the Sym Runtime and its associated resources in Sym and AWS
runtime_name = "prod"

slack_workspace_id = "CHANGEME" # Slack Workspace where Sym is installed

# Your org slug will be provided to you by your Sym onboarding team
sym_org_slug = "CHANGEME"

# Optionally add more tags to the AWS resources we create
tags = {
  "vendor" = "symops.com"
}
