terraform {
  required_providers {
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = "2.2.0"
    }
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.50.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.4"
    }
  }
}

provider "hetznerdns" {
  apitoken = var.hetzner_dns_apitoken
}

provider "hcloud" {
  token = var.hetzner_cloud_apitoken
}

provider "random" {}
provider "external" {}
