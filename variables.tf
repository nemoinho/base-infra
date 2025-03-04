variable "hetzner_apitoken" {
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
