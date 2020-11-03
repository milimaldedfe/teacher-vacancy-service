# module prometheus_all {
#   source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all?ref=monitoring-terraform-0_13"

#   name                    = var.name
#   space_id                = data.cloudfoundry_space.monitoring.id
#   paas_exporter_username  = var.paas_exporter_username
#   paas_exporter_password  = var.paas_exporter_password
#   alertmanager_config     = file("${path.module}/files/alertmanager.yml")
#   grafana_admin_password  = var.grafana_admin_password
#   grafana_json_dashboards = [file("${path.module}/files/paas_dashboard.json")]
#   alert_rules             = file("${path.module}/files/alert.rules")
# }

module prometheus_all {
  source = "git::https://github.com/DFE-Digital/bat-platform-building-blocks.git//terraform/modules/prometheus_all?ref=monitoring-terraform-0_13-tv"

  monitoring_instance_name                    = var.monitoring_instance_name
  #enabled_modules = ["paas_prometheus_exporter", "prometheus", "grafana", "alertmanager"]
  # enabled_modules = ["influxdb"]
  enabled_modules = ["paas_prometheus_exporter", "prometheus", "alertmanager", "influxdb", "grafana"]

  paas_password = local.paas_password
  paas_sso_code = local.paas_sso_passcode
  paas_user     = local.paas_user

  monitoring_org_name   = local.monitoring_org_name
  monitoring_space_name = local.monitoring_space_name

  paas_exporter_config = {
    API_ENDPOINT = local.paas_api_url
    USERNAME     = var.paas_exporter_username
    PASSWORD     = var.paas_exporter_password
  }

  grafana_config = {
    dashboard_directory  = "${path.module}/grafana_dashboards"
    google_client_id     = var.grafana_google_client_id
    google_client_secret = var.grafana_google_client_secret
  }
  grafana_admin_password = var.grafana_admin_password

  alertmanager_config = file("${path.module}/config/alert-manager.yml")
  alert_rules         = file("${path.module}/config/alert.rules")
}
