resource "hcloud_ssh_key" "this" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = each.value
}

module "k8s" {
  source = "./modules/hetzner/kubernetes"

  name     = "cluster1"
  ssh_keys = [for o in hcloud_ssh_key.this : o.id]
  servers = [for n in range(var.k8s_server_count) : {
    type          = var.k8s_server_type
    location      = var.k8s_location
    ip_datacenter = var.k8s_ip_datacenter
  }]
  agents = [{
    type     = var.k8s_agent_type
    location = var.k8s_location
    count    = var.k8s_agent_count
  }]
  auto_delete_primary_ips = false
  kubernetes_exposed_ips  = var.kubernetes_allowed_ips
  ssh_exposed_ips         = var.ssh_allowed_ips
  ssh_port                = 1022
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
          { name = "@", type = "A", value = module.k8s.server_ips_v4[0] },
          { name = "*", type = "A", value = module.k8s.server_ips_v4[0] },
        ] : [],
        values.default_AAAA ? [
          { name = "@", type = "AAAA", value = module.k8s.server_ips_v6[0] },
          { name = "*", type = "AAAA", value = module.k8s.server_ips_v6[0] },
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

