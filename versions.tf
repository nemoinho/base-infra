terraform {
  required_providers {
    hetznerdns = {
      source = "timohirt/hetznerdns"
      version = "2.2.0"
    }
  }
}

provider "hetznerdns" {
  apitoken = var.hetzner_dns_apitoken
}
