variable "NUTANIX_USERNAME" {}
variable "NUTANIX_PASSWORD" {}
variable "NUTANIX_ENDPOINT" {}
variable "NUTANIX_INSECURE" {}
variable "NUTANIX_PORT" {}
variable "NUTANIX_WAIT_TIMEOUT" {}

//External VLAN
variable "EXTERNAL_SUBNET" {
  type = string
  default = ""
}



