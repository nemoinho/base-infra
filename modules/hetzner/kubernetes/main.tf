locals {
  network           = "10.0.0.0/16"
  subnet_eu_central = "10.0.0.0/24"
  servers = {
    for idx, config in var.servers : "${var.name}-server-${idx + 1}" => merge(
      config,
      {
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
  name = var.name
  rule {
    direction = "in"
    protocol = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol = "tcp"
    port = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol = "tcp"
    port = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol = "tcp"
    port = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
  rule {
    direction = "in"
    protocol = "tcp"
    port = "6443"
    source_ips = concat([local.network], var.development_ips)
  }
  dynamic "rule" {
    for_each = length(var.development_ips) == 0 ? {} : { ips = 1 }
    content {
      direction = "in"
      protocol = "tcp"
      port = "1022"
      source_ips = var.development_ips
    }
  }
}

resource "hcloud_server" "server" {
  depends_on  = [hcloud_network_subnet.this]
  for_each    = local.servers
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
  user_data = templatefile(
    "${path.module}/server-init.yaml.tftpl",
    {
      network_ip_range = local.network
      k3s_token        = random_string.k3s_token.result
      first_ip         = each.value.first_ip
    }
  )
  firewall_ids = [hcloud_firewall.this.id]
}

resource "hcloud_server" "agent" {
  depends_on = [hcloud_server.server]
  for_each   = local.agents

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
  user_data = templatefile(
    "${path.module}/agent-init.yaml.tftpl",
    {
      server_ip       = cidrhost(local.subnet_eu_central, 2)
      network_gateway = cidrhost(local.subnet_eu_central, 1)
      dns_servers     = "8.8.8.8 8.8.4.4"
      k3s_token       = random_string.k3s_token.result
    }
  )
}
