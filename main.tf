resource "hcloud_ssh_key" "this" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = each.value
}

resource "hcloud_primary_ip" "k8s_ipv4" {
  name          = "k8s_primary_ipv4"
  datacenter    = "fsn1-dc14"
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = false # change to true and apply before deleting!
}

resource "hcloud_primary_ip" "k8s_ipv6" {
  name          = "k8s_primary_ipv6"
  datacenter    = "fsn1-dc14"
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = false # change to true and apply before deleting!
}

data "external" "my_ip" {
  program = [
    "sh",
    "-c",
    "(dig TXT +short -4 o-o.myaddr.l.google.com @ns1.google.com && dig TXT +short -6 o-o.myaddr.l.google.com @ns1.google.com) | jq '{(.): .}' | jq -s add"
  ]
}

module "k8s" {
  source = "./modules/hetzner/kubernetes"

  name     = "cluster1"
  ssh_keys = [for o in hcloud_ssh_key.this : o.id]
  # Ensure a odd number of definitions, since only that make any sense
  servers = [{
    ipv4_id  = hcloud_primary_ip.k8s_ipv4.id
    ipv6_id  = hcloud_primary_ip.k8s_ipv6.id
    type     = "cax11"
    location = "fsn1"
  }]
  agents = [{
    type     = "cax11"
    location = "fsn1"
    count    = 1
  }]
  kubernetes_exposed_ips = values(data.external.my_ip.result)
  ssh_exposed_ips        = values(data.external.my_ip.result)
  public_tcp_services = {
    http = ["80", "443"]
  }
}

locals {
  dns_zones = {
    # costs-table (incl. taxes):
    #  domain | amount | hetzner (einzel) | tecspace (einzel)
    # --------+--------+------------------+-------------------
    #      de |      3 |  35.70€ (11.90€) |  15.85€   (5.95€)
    #    info |      1 |  30.94€ (30.94€) |  21.95€  (21.95€)
    #     net |      2 |  33.32€ (16.66€) |  35.90€  (17.95€)
    #     org |      1 |  17.85€ (17.85€) |  21.95€  (21.95€)
    # --------+--------+------------------+-------------------
    #     sum |      7 | 117.21€          |  97.65€
    #
    # Note, that Hetzner usually shows prices w/o taxes!
    #
    # Reference: https://www.hetzner.com/de/whois/
    # Reference: https://www.tecspace.de/domain-preisliste
    "goperte.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
      ]
    },
    "nehrke.info" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "@", ttl = 86400, type = "MX", value = "1 smtp.google.com." },
        { name = "@", ttl = 86400, type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
        { name = "_dmarc", ttl = 86400, type = "TXT", value = "v=DMARC1; p=none;" },
        { name = "google._domainkey", ttl = 86400, type = "TXT", value = var.nehrke_info_dkim },
      ]
    },
    "sozpaedil.net" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "@", ttl = 86400, type = "MX", value = "1 smtp.google.com." },
        { name = "@", ttl = 86400, type = "TXT", value = "v=spf1 include:_spf.google.com a mx ~all" },
        { name = "_dmarc", ttl = 86400, type = "TXT", value = "v=DMARC1; p=none;" },
        { name = "google._domainkey", ttl = 86400, type = "TXT", value = var.sozpaedil_net_dkim },
      ]
    },
    "tovot.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
      ]
    },
    "tovot.net" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
      ]
    },
    "tovot.org" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
      ]
    },
    "xn--alleingnger-r8a.de" = {
      zone_ttl = 900
      records = [
        { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4.ip_address },
        { name = "@", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
        { name = "*", type = "AAAA", value = hcloud_primary_ip.k8s_ipv6.ip_address },
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

