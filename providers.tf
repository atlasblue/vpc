terraform {
  required_providers {
    nutanix = {
      source  = "nutanix/nutanix"
      version = "1.8.0-beta.1"
    }
  }
}

provider "nutanix" {
  username = var.NUTANIX_USERNAME
  password = var.NUTANIX_PASSWORD
  endpoint = var.NUTANIX_ENDPOINT
  port     = var.NUTANIX_PORT
  insecure = var.NUTANIX_INSECURE
  #wait_timeout = var.NUTANIX_WAIT_TIMEOUT
  #foundation_endpoint = var.FOUNDATION_ENDPOINT #version 1.7.1
  #foundation_port     = var.FOUNDATION_PORT #version 1.7.1
}