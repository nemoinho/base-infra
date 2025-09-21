variable "zone" {
  type = string
}

variable "zone_ttl" {
  type = number
  default = 3600
}

variable "records" {
  type = set(object({
    name = string
    value = string
    type = string
    ttl = optional(number, null)
  }))
  default = []
}

