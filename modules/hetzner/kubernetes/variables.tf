variable "name" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}

variable "servers" {
  type = list(object({
    type          = string
    location      = string
    ip_datacenter = string
  }))
}

variable "agents" {
  type = list(object({
    count    = optional(number, 1)
    type     = string
    location = string
  }))
}

variable "ping_enabled" {
  type    = bool
  default = true
}

variable "public_tcp_services" {
  type    = map(list(string))
  default = {}
}

variable "kubernetes_exposed_ips" {
  type    = list(string)
  default = []
}

variable "ssh_exposed_ips" {
  type    = list(string)
  default = []
}

variable "ssh_port" {
  type    = number
  default = 1022
}

variable "auto_delete_primary_ips" {
  default     = true
  description = <<EOF
  Set this to "false" to keep the primary IPs bound to your Hetzner-Account, even after a destroy.
  This setting would allow for reuse of the same IPs between multiple create/destroy cycles.
  Though, it doesn't guarantee reuse of the same IPs.

  Note, that reserved IPs will create costs, even if they're not used.
  EOF
}
