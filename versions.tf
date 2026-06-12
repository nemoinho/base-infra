terraform {
  backend "s3" {
    bucket = "nemoinho-tfstate"
    key    = "base-infra/terraform.tfstate"
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
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.8.1"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.5"
    }
  }
}

provider "hcloud" {
  token = var.hetzner_cloud_apitoken
}

provider "random" {}

provider "external" {}
