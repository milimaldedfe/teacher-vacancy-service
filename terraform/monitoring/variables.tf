variable paas_sso_passcode {
  default = ""
}

variable paas_store_tokens_path {
  default = ""
}

variable paas_username {
  default = ""
}

variable paas_password {
  default = ""
}


variable paas_exporter_username {}

variable paas_exporter_password {}

variable monitoring_instance_name {
  default = "teaching-vacancies"
}

variable grafana_admin_password {
  default = "APassword"
}

variable grafana_google_client_id {
  default = ""
}

variable grafana_google_client_secret {
  default = ""
}

variable monitoring_env {
  default = "prod"
}

locals {
  paas_api_url        = "https://api.london.cloud.service.gov.uk"
  monitoring_org_name = "dfe-teacher-services"
  space_name = {
    monitoring = "teaching-vacancies-monitoring"
  }
  monitoring_space_name = "teaching-vacancies-monitoring"
  paas_password         = var.paas_password != "" ? var.paas_password : null
  paas_sso_passcode     = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  paas_user             = var.paas_username != "" ? var.paas_username : null
}
