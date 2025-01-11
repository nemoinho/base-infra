variable "hetzner_apitoken" {
  type = string
}

variable "google_dkim" {
  type = map(string)
}

variable "gmail_dns_default_ttl" {
  type    = number
  default = 3600
}

