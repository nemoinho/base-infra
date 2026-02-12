terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
      version = ">= 1.60.0"
    }
    random = {
      source = "hashicorp/random"
      version = ">= 3.8.1"
    }
  }
}


