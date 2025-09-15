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

variable "nehrke_info_dkim" {
  type      = string
  sensitive = true
}

variable "sozpaedil_net_dkim" {
  type      = string
  sensitive = true
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

variable "k3s_version" {
  type        = string
  description = "The k3s version to use."
}
