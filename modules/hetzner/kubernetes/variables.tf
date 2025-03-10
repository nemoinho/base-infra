variable "name" {
  type = string
}

variable "ssh_keys" {
  type = list(string)
}

variable "servers" {
  type = list(object({
    ipv4_id  = number
    ipv6_id  = number
    type     = string
    location = string
  }))
}

variable "agents" {
  type = list(object({
    count    = optional(number, 1)
    type     = string
    location = string
  }))
}

variable "development_ips" {
  type    = list(string)
  default = []
}
