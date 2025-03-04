module "dns_goperte_de" {
  source   = "./modules/hetzner/dns"
  zone     = "goperte.de"
  zone_ttl = 900
  records  = [
    { name = "@", type = "A", value = "62.138.6.205" },
    { name = "*", type = "A", value = "62.138.6.205" },
  ]
}

module "dns_nehrke_info" {
  source   = "./modules/hetzner/dns"
  zone     = "nehrke.info"
  zone_ttl = 3600
  records  = [
    { name = "@", ttl = 900, type = "A", value = "62.138.6.205" },
    { name = "*", ttl = 900, type = "A", value = "62.138.6.205" },
    { name = "@", type = "MX", value = "1 smtp.google.com." },
    { name = "@", type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
    { name = "_dmarc", type = "TXT", value = "v=DMARC1; p=none;" },
    { name = "google._domainkey", type = "TXT", value = var.nehrke_info_dkim },
  ]
}

module "dns_sozpaedil_net" {
  source   = "./modules/hetzner/dns"
  zone     = "sozpaedil.net"
  zone_ttl = 3600
  records  = [
    { name = "@", ttl = 900, type = "A", value = "62.138.6.205" },
    { name = "*", ttl = 900, type = "A", value = "62.138.6.205" },
    { name = "@", type = "MX", value = "1 smtp.google.com." },
    { name = "@", type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
    { name = "_dmarc", type = "TXT", value = "v=DMARC1; p=none;" },
    { name = "google._domainkey", type = "TXT", value = var.sozpaedil_net_dkim },
  ]
}

module "dns_tovot_de" {
  source   = "./modules/hetzner/dns"
  zone     = "tovot.de"
  zone_ttl = 900
  records  = [
    { name = "@", type = "A", value = "62.138.6.205" },
    { name = "*", type = "A", value = "62.138.6.205" },
  ]
}

module "dns_tovot_net" {
  source   = "./modules/hetzner/dns"
  zone     = "tovot.net"
  zone_ttl = 900
  records  = [
    { name = "@", type = "A", value = "62.138.6.205" },
    { name = "*", type = "A", value = "62.138.6.205" },
  ]
}

module "dns_tovot_org" {
  source   = "./modules/hetzner/dns"
  zone     = "tovot.org"
  zone_ttl = 900
  records  = [
    { name = "@", type = "A", value = "62.138.6.205" },
    { name = "*", type = "A", value = "62.138.6.205" },
  ]
}

module "dns_xn--alleingnger-r8a_de" {
  source   = "./modules/hetzner/dns"
  zone     = "xn--alleingnger-r8a.de"
  zone_ttl = 900
  records  = [
    { name = "@", type = "A", value = "62.138.6.205" },
    { name = "*", type = "A", value = "62.138.6.205" },
  ]
}

