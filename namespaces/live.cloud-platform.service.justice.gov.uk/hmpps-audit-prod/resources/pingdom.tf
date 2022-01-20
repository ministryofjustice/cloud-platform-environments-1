provider "pingdom" {
}

# Integration IDs
# 96624 = #dps_alerts
# 96628 = DPS Pager duty

resource "pingdom_check" "hmpps-audit-api-production-check" {
  type                     = "http"
  name                     = "DPS - HMPPS Audit API"
  host                     = "health-kick.prison.service.justice.gov.uk"
  resolution               = 1
  notifywhenbackup         = true
  sendnotificationwhendown = 6
  notifyagainevery         = 0
  url                      = "/https/${var.domain_audit_api}"
  encryption               = true
  port                     = 443
  tags                     = "dps,hmpps,cloudplatform-managed"
  probefilters             = "region:EU"
  integrationids           = [96624, 96628]
}
