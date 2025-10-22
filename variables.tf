variable "kubernetes_allowed_ips" {
  type        = set(string)
  description = "A set of IPs (IPv4 and IPv6) which have access to the kubernetes API."
  default     = []
}

variable "ssh_allowed_ips" {
  type        = set(string)
  description = "A set of IPs (IPv4 and IPv6) which can access the cluster via SSH."
  default     = []
}

variable "add_local_ip_to_kubernetes_allowed_ips" {
  default = true
  description = "Whether to add the current local ip to the set of IPs which have access to the kubernetes API."
}

variable "add_local_ip_to_ssh_allowed_ips" {
  default = true
  description = "Whether to add the current local ip to the set of IPs which have access to the cluster via SSH."
}

variable "hetzner_dns_apitoken" {
  type = string
}

variable "hetzner_cloud_apitoken" {
  type = string
}

variable "ssh_keys" {
  type = map(string)
}

variable "k8s_servers" {
  type = list(object({
    type          = optional(string, "cax11")
    location      = string
    ip_datacenter = string
  }))
  description = <<EOF
  The servers of the kubernetes-cluster.
  This should always contain an off number of servers.
  An overview of locations can be found at: https://docs.hetzner.com/cloud/general/locations/
  Note, that the ip_datacenter has to match the location.
  EOF
}

variable "k8s_agents" {
  type = list(object({
    type     = optional(string, "cax11")
    location = string
    count    = optional(number, 1)
  }))
  description = <<EOF
  The agents of the kubernetes-cluster.
  An overview of locations can be found at: https://docs.hetzner.com/cloud/general/locations/
  EOF
}

variable "dns_zones" {
  type = map(object({
    zone_ttl = optional(number, 900)
    default_A = optional(bool, true)
    default_AAAA = optional(bool, true)
    custom_records = optional(set(object({
      name = string
      value = string
      type = string
      ttl = optional(number, null)
    })), [])
  }))
  description = <<EOF
  A map of dns-zones to be configured in the hetzner-dns system.
  The fields default_A and default_AAAA control if the records gets a default A and AAAA record.
  This default-record will point to the kubernetes-cluster.
  If this is not desired, simply set these to false and apply a custom-record.
  EOF
}
