variable "hetzner_dns_apitoken" {
  type = string
}

variable "hetzner_cloud_apitoken" {
  type = string
}

variable "nehrke_info_dkim" {
  type      = string
  sensitive = true
}

variable "sozpaedil_net_dkim" {
  type      = string
  sensitive = true
}

variable "ssh_keys" {
  type = map(string)
}

