resource "hcloud_primary_ip" "ipv4" {
  count = length(var.servers)

  name          = "k8s_primary_ipv4_${count.index}"
  datacenter    = var.servers[count.index].ip_datacenter
  type          = "ipv4"
  assignee_type = "server"
  auto_delete   = var.auto_delete_primary_ips
}

resource "hcloud_primary_ip" "ipv6" {
  count = length(var.servers)

  name          = "k8s_primary_ipv6_${count.index}"
  datacenter    = var.servers[count.index].ip_datacenter
  type          = "ipv6"
  assignee_type = "server"
  auto_delete   = var.auto_delete_primary_ips
}

locals {
  network           = "10.0.0.0/16"
  subnet_eu_central = "10.0.0.0/24"
  servers = {
    for idx, config in var.servers : "${var.name}-server-${idx + 1}" => merge(
      config,
      {
        ipv4_id  = hcloud_primary_ip.ipv4[idx].id
        ipv6_id  = hcloud_primary_ip.ipv6[idx].id
        ip       = cidrhost(local.subnet_eu_central, idx + 2)
        first_ip = idx == 0 ? "" : cidrhost(local.subnet_eu_central, 2)
      }
    )
  }
  agents = merge([
    for idx, config in var.agents : {
      for n in range(0, config.count) : "${var.name}-agent-${idx + 1}-${n + 1}" => merge(
        config,
        { ip = cidrhost(local.subnet_eu_central, 255 - (idx * 20) - n - 1) }
      )
    }
  ]...)
  all_ips           = ["0.0.0.0/0", "::/0"]
  ping_firewall     = var.ping_enabled ? { "ping" : [{ protocol = "icmp", port = null }] } : {}
  k8s_firewall      = { "kubernetes" : [{ port = "6443", source_ips = concat([local.network], var.kubernetes_exposed_ips) }] }
  ssh_firewall      = length(var.ssh_exposed_ips) > 0 ? { "ssh" : [{ port = var.ssh_port, source_ips = var.ssh_exposed_ips }] } : {}
  service_firewalls = { for service, ports in var.public_tcp_services : service => [for port in ports : { port = port }] }
  firewalls = merge(
    local.ping_firewall,
    local.k8s_firewall,
    local.ssh_firewall,
    local.service_firewalls
  )
}

resource "hcloud_network" "this" {
  name     = var.name
  ip_range = local.network
}

resource "hcloud_network_subnet" "this" {
  type         = "cloud"
  network_id   = hcloud_network.this.id
  network_zone = "eu-central"
  ip_range     = local.subnet_eu_central
}

resource "hcloud_network_route" "this" {
  network_id  = hcloud_network.this.id
  destination = "0.0.0.0/0"
  gateway     = cidrhost(local.subnet_eu_central, 2)
}

resource "random_string" "k3s_token" {
  length  = 100
  special = false
}

resource "hcloud_firewall" "this" {
  for_each = local.firewalls

  name = each.key
  dynamic "rule" {
    for_each = each.value
    content {
      direction  = lookup(rule.value, "direction", "in")
      protocol   = lookup(rule.value, "protocol", "tcp")
      source_ips = lookup(rule.value, "source_ips", local.all_ips)
      port       = lookup(rule.value, "port")
    }
  }
}
resource "hcloud_server" "server" {
  depends_on  = [hcloud_network_subnet.this]
  for_each    = local.servers

  lifecycle {
    ignore_changes = [ user_data ]
  }

  name        = each.key
  image       = "ubuntu-24.04"
  server_type = each.value.type
  location    = each.value.location
  ssh_keys    = var.ssh_keys
  public_net {
    ipv4 = each.value.ipv4_id
    ipv6 = each.value.ipv6_id
  }
  network {
    network_id = hcloud_network.this.id
    ip         = each.value.ip
  }
  firewall_ids = [for firewall in hcloud_firewall.this : firewall.id]
}

resource "hcloud_server" "agent" {
  depends_on = [hcloud_server.server]
  for_each   = local.agents

  lifecycle {
    ignore_changes = [ user_data ]
  }

  name        = each.key
  image       = "ubuntu-24.04"
  server_type = each.value.type
  location    = each.value.location
  ssh_keys    = var.ssh_keys
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
  network {
    network_id = hcloud_network.this.id
    ip         = each.value.ip
  }
}
