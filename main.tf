locals {
  dns_zones = {
    # costs-table:
    #  domain | amount | hetzner (einzel) | hetzner konsoleH (einzel) | tecspace (einzel)
    # --------+--------+------------------+---------------------------+-------------------
    #      de |      3 | 30.00€  (10.00€) |  35.70€          (11.90€) | 15.85€    (5.95€)
    #    info |      1 | 26.00€  (26.00€) |  30.94€          (30.94€) | 21.95€   (21.95€)
    #     net |      2 | 28.00€  (14.00€) |  33.32€          (16.66€) | 35.90€   (17.95€)
    #     org |      1 | 15.00€  (15.00€) |  17.85€          (17.85€) | 21.95€   (21.95€)
    # --------+--------+------------------+---------------------------+--------------------
    #     sum |      7 | 99.00€           | 117.21€                   | 97.65€
    "goperte.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = "62.138.6.205" },
        { name = "*", type = "A", value = "62.138.6.205" },
      ]
    },
    "nehrke.info" = {
      zone_ttl = 3600
      records = [
        { name = "@", ttl = 900, type = "A", value = "62.138.6.205" },
        { name = "*", ttl = 900, type = "A", value = "62.138.6.205" },
        { name = "@", type = "MX", value = "1 smtp.google.com." },
        { name = "@", type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
        { name = "_dmarc", type = "TXT", value = "v=DMARC1; p=none;" },
        { name = "google._domainkey", type = "TXT", value = var.nehrke_info_dkim },
      ]
    },
    "sozpaedil.net" = {
      zone_ttl = 3600
      records = [
        { name = "@", ttl = 900, type = "A", value = "62.138.6.205" },
        { name = "*", ttl = 900, type = "A", value = "62.138.6.205" },
        { name = "@", type = "MX", value = "1 smtp.google.com." },
        { name = "@", type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
        { name = "_dmarc", type = "TXT", value = "v=DMARC1; p=none;" },
        { name = "google._domainkey", type = "TXT", value = var.sozpaedil_net_dkim },
      ]
    },
    "tovot.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = "62.138.6.205" },
        { name = "*", type = "A", value = "62.138.6.205" },
      ]
    },
    "tovot.net" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = "62.138.6.205" },
        { name = "*", type = "A", value = "62.138.6.205" },
      ]
    },
    "tovot.org" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = "62.138.6.205" },
        { name = "*", type = "A", value = "62.138.6.205" },
      ]
    },
    "xn--alleingnger-r8a.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = "62.138.6.205" },
        { name = "*", type = "A", value = "62.138.6.205" },
      ]
    },
  }
}

module "dns" {
  source   = "./modules/hetzner/dns"
  for_each = local.dns_zones
  zone     = each.key
  zone_ttl = lookup(each.value, "zone_ttl")
  records  = lookup(each.value, "records")
}

resource "hcloud_ssh_key" "this" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = each.value
}

