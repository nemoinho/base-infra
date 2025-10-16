resource "hcloud_ssh_key" "this" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = each.value
}

resource "hcloud_primary_ip" "k8s_ipv4" {
  count = var.k8s_server_count < 1 ? 1 : var.k8s_server_count

  name          = "k8s_primary_ipv4_${count.index}"
  datacenter    = var.k8s_ip_datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = !var.k8s_test_installation
}

resource "hcloud_primary_ip" "k8s_ipv6" {
  count = var.k8s_server_count < 1 ? 1 : var.k8s_server_count

  name          = "k8s_primary_ipv6_${count.index}"
  datacenter    = var.k8s_ip_datacenter
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = !var.k8s_test_installation
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
  servers = [for n in range(var.k8s_server_count) : {
    ipv4_id  = hcloud_primary_ip.k8s_ipv4[n].id
    ipv6_id  = hcloud_primary_ip.k8s_ipv6[n].id
    type     = var.k8s_server_type
    location = var.k8s_location
  }]
  agents = [{
    type     = var.k8s_agent_type
    location = var.k8s_location
    count    = var.k8s_agent_count
  }]
  kubernetes_exposed_ips = var.expose_kubernetes_and_ssh_ports ? values(data.external.my_ip.result) : []
  ssh_exposed_ips        = var.expose_kubernetes_and_ssh_ports ? values(data.external.my_ip.result) : []
  ssh_port               = 1022
  public_tcp_services = {
    git-ssh = ["22"]
    http = ["80", "443"]
  }
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/inventory.ini"
  content = templatefile("./inventory.ini.tftpl", {
    server_ips   = module.k8s.server_ips_v4,
    agent_ips    = module.k8s.agent_ips_v4,
    network_cidr = module.k8s.private_network_cidr,
    private_nat  = module.k8s.private_network_nat,
    ssh_port     = module.k8s.ssh_port,
  })
}

locals {
  dns_zones = {
    for key, values in var.dns_zones : key => {
      zone_ttl = values.zone_ttl
      records = toset(concat(
        values.default_A ? [
          { name = "@", type = "A", value = hcloud_primary_ip.k8s_ipv4[0].ip_address },
          { name = "*", type = "A", value = hcloud_primary_ip.k8s_ipv4[0].ip_address },
        ] : [],
        values.default_AAAA ? [
          { name = "@", type = "AAAA", value = "${hcloud_primary_ip.k8s_ipv6[0].ip_address}1" },
          { name = "*", type = "AAAA", value = "${hcloud_primary_ip.k8s_ipv6[0].ip_address}1" },
        ] : [],
        tolist(values.custom_records)
      ))
    }
  }
}

module "dns" {
  source   = "./modules/hetzner/dns"
  for_each = local.dns_zones
  zone     = each.key
  zone_ttl = lookup(each.value, "zone_ttl")
  records  = lookup(each.value, "records")
}

