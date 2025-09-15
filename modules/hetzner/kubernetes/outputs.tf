output "server_ips_v4" {
  value = [for key, value in hcloud_server.server : value.ipv4_address]
}

output "server_ips_v6" {
  value = [for key, value in hcloud_server.server : value.ipv6_address]
}

output "agent_ips_v4" {
  value = flatten([for key, value in hcloud_server.agent : value.network.*.ip])
}
