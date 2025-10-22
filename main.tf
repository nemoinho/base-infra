resource "hcloud_ssh_key" "this" {
  for_each   = var.ssh_keys
  name       = each.key
  public_key = each.value
}

data "external" "current_ips" {
  count = var.add_local_ip_to_ssh_allowed_ips || var.add_local_ip_to_kubernetes_allowed_ips ? 1 : 0
  program = [
    "sh",
    "-c",
    "(ip -6 route show | awk '/proto ra metric/&&!/^default/{print $1}'; curl -s ipinfo.io/ip; echo /32) | jq -R '{(.): .}' | jq -s add"
  ]
}

locals {
  current_ips = flatten([ for value in data.external.current_ips.*.result : values(value) ])
  kubernetes_allowed_ips = toset(
    concat(
      tolist(var.kubernetes_allowed_ips), 
      var.add_local_ip_to_kubernetes_allowed_ips ? local.current_ips : []
    )
  )
  ssh_allowed_ips = toset(
    concat(
      tolist(var.ssh_allowed_ips),
      var.add_local_ip_to_ssh_allowed_ips ? local.current_ips : []
    )
  )
}

module "k8s" {
  source = "./modules/hetzner/kubernetes"

  name                    = "cluster1"
  ssh_keys                = [for o in hcloud_ssh_key.this : o.id]
  servers                 = var.k8s_servers
  agents                  = var.k8s_agents
  auto_delete_primary_ips = false
  kubernetes_exposed_ips  = local.kubernetes_allowed_ips
  ssh_exposed_ips         = local.ssh_allowed_ips
  ssh_port                = 1022
  public_tcp_services = {
    git-ssh = ["22"]
    http    = ["80", "443"]
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

