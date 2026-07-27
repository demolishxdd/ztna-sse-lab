terraform {
  required_version = ">= 1.5.0"

  required_providers {
    scm = {
      source  = "PaloAltoNetworks/scm"
      version = ">= 1.0.0"
    }
  }
}

provider "scm" {
  host          = "api.sase.paloaltonetworks.com"
  client_id     = var.scm_client_id
  client_secret = var.scm_client_secret
  scope         = "tsg_id:${var.scm_tsg_id}"
}
