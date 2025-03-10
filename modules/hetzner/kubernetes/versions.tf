terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = "1.50.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.7.1"
    }
  }
}


