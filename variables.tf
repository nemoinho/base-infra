variable "expose_kubernetes_and_ssh_ports" {
  type    = bool
  default = false
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

variable "k8s_test_installation" {
  default     = false
  description = <<EOF
  When this is set to true we configure primary-ips to not be deleted automatically!
  This allows us to reuse the same IP for multiple create/destroy cycles.
  As soon as the test-phase is over this should be false.
  EOF
}

# Right now this only supports 1 location, but that's okay for me!
variable "k8s_location" {
  type        = string
  description = <<EOF
  This is the location where I host the k8s-cluster.
  An overview of possible locations can be found at: https://docs.hetzner.com/cloud/general/locations/
  EOF
}

variable "k8s_ip_datacenter" {
  type        = string
  description = <<EOF
  This is the datacenter where the public IPs of the k8s-cluster belong to.
  An overview of possible locations can be found at: https://docs.hetzner.com/cloud/general/locations/
  Note, that the k8s_ip_datacenter has to match the k8s_location!
  EOF
}

variable "k8s_server_count" {
  type        = number
  default     = 3
  description = "Number of k8s-server nodes. This should always be an odd number."
}

variable "k8s_server_type" {
  type    = string
  default = "cax11"
}

variable "k8s_agent_count" {
  type    = number
  default = 3
}

variable "k8s_agent_type" {
  type    = string
  default = "cax11"
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
