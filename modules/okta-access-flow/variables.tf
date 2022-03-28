variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python."
  type        = map(string)
}

variable "okta_org_domain" {
  description = "Domain of the Okta account to use for this flow. Example: 'my-org.okta.com'."
  type        = string
}

variable "secret_json_key" {
  description = "Name of the key that maps to the Okta API key within your Secrets Manager Secret."
  type        = string
  default     = "okta_api_token"
}

variable "secrets_settings" {
  description = "Secrets source and path for shared secret lookups."
  type = object(
    { source_id = string, path = string }
  )
}

variable "sym_environment" {
  description = "Sym Environment for this Flow."
  type        = object({ id = string, name = string })
}

variable "targets" {
  description = "List of Okta targets that end-users can request access to. Each object has a label and a group_id."
  type = list(object(
    { label = string, group_id = string }
  ))
}
