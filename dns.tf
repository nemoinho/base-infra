locals {
  // gmail had a different dns-setting in the past,
  // but they claim it's still totally valid for old installations
  // they even guarantee to keep it valid in future
  // see: https://support.google.com/a/answer/174125?hl=en#zippy=%2Cgoogle-workspace-legacy-version-before
  dns_gmail_until_april_2023 = [
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "1 aspmx.l.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "5 alt1.aspmx.l.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "5 alt2.aspmx.l.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "10 alt3.aspmx.l.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "10 alt1.aspmx.l.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
  ]
  dns_gmail_starting_april_2023 = [
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "MX", value = "1 smtp.google.com." },
    { name = "@", ttl = var.gmail_dns_default_ttl, type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
  ]
  dns_website_default = [
    { name = "@", ttl = 900, type = "A", value = "62.138.6.205" },
    { name = "*", ttl = 900, type = "A", value = "62.138.6.205" },
  ]
}

module "dns_goperte_de" {
  source   = "./dns"
  zone     = "goperte.de"
  records  = local.dns_website_default
}

module "dns_nehrke_info" {
  source   = "./dns"
  zone     = "nehrke.info"
  records  = concat(
    local.dns_website_default,
    [
      { name = "_dmarc", ttl = var.gmail_dns_default_ttl, type = "TXT", value = "v=DMARC1; p=none;" },
      { name = "google._domainkey", ttl = var.gmail_dns_default_ttl, type = "TXT", value = var.google_dkim["nehrke.info"] }
    ],
    local.dns_gmail_until_april_2023,
  )
}

module "dns_sozpaedil_net" {
  source   = "./dns"
  zone     = "sozpaedil.net"
  records  = concat(
    local.dns_website_default,
    [
      { name = "_dmarc", ttl = var.gmail_dns_default_ttl, type = "TXT", value = "v=DMARC1; p=none;" },
      { name = "google._domainkey", ttl = var.gmail_dns_default_ttl, type = "TXT", value = var.google_dkim["sozpaedil.net"] }
    ],
    local.dns_gmail_until_april_2023,
  )
}

module "dns_tovot_de" {
  source   = "./dns"
  zone     = "tovot.de"
  records  = local.dns_website_default
}

module "dns_tovot_net" {
  source   = "./dns"
  zone     = "tovot.net"
  records  = local.dns_website_default
}

module "dns_tovot_org" {
  source   = "./dns"
  zone     = "tovot.org"
  records  = local.dns_website_default
}

module "dns_xn--alleingnger-r8a_de" {
  source   = "./dns"
  zone     = "xn--alleingnger-r8a.de"
  records  = local.dns_website_default
}

