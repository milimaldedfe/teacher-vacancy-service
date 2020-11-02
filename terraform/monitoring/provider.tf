provider cloudfoundry {
  api_url           = local.paas_api_url
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.sso_passcode != "" ? var.sso_passcode : null
  store_tokens_path = "./tokens"
  user              = var.paas_username
}
