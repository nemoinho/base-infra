hetzner_dns_apitoken   = "YOUR_HETZNER_DNS_API_TOKEN"
hetzner_cloud_apitoken = "YOUR_HETZNER_CLOUD_API_TOKEN"

# Hetzner-locations: https://docs.hetzner.com/cloud/general/locations/
k8s_servers = [
  { type = "cax11", location = "fsn1", ip_datacenter = "fsn1-dc14" }
]
k8s_agents = [
  { type = "cax11", location = "fsn1" }
]

ssh_keys = {
  "SSH_KEY_NAME" = "YOUR_PUBLIC_SSH_KEY"
}

dns_zones = {
  "example.com" = {
    custom_records = [
      { name = "@", ttl = 86400, type = "TXT", value = "HELLO" }
    ]
  }
  "example.net" = {}
}
