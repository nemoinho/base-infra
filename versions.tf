terraform {
  backend "s3" {
    bucket = "nemoinho-tfstate"
    key    = "hetzner-infra/terraform.tfstate"
    region = "eu-central-003"
    endpoints = {
      s3 = "https://s3.eu-central-003.backblazeb2.com"
    }
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_metadata_api_check     = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
  }

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
