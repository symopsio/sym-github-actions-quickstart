# Send errors during Flow execution to a shared logging channel
resource "sym_error_logger" "slack" {
  integration_id = sym_integration.slack.id
  destination    = var.error_channel
}

# A sym environment collects together a group of integrations to simplify
# Flow configuration.
resource "sym_environment" "this" {
  name            = var.runtime_name
  runtime_id      = sym_runtime.this.id
  error_logger_id = sym_error_logger.slack.id

  integrations = {
    slack_id = sym_integration.slack.id
  }
}
