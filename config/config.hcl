prometheus "prod" {
  timeout = "30s"
  include = [
    "namespace/live.cloud-platform.service.justice.gov.uk/.+prod/.+prometheusrules.yaml",
    "namespace/live-2.cloud-platform.service.justice.gov.uk/.+prod/.+prometheusrules.yml"
  ]
}

prometheus "dev" {
  timeout = "60s"
  exclude = [
    "namespace/live.cloud-platform.service.justice.gov.uk/.+prod/.+prometheusrules.yaml",
    "namespace/live-2.cloud-platform.service.justice.gov.uk/.+prod/.+prometheusrules.yml"
  ]
}

