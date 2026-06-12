resource "hcloud_zone" "this" {
  name = var.zone
  mode = "primary"
  ttl  = var.zone_ttl
}

locals {
  records = nonsensitive({
    for record in var.records : "${record.type}#${record.name}#${md5(record.value)}" => {
      for key, value in record : key => value
    }
  })
}

resource "hcloud_zone_rrset" "this" {
  for_each = local.records
  zone  = hcloud_zone.this.name
  name  = each.value.name
  type  = each.value.type
  records = [{
    value = (each.value.type == "TXT"
      ? "\"${join("\" \"", [for c in chunklist(split("", each.value.value), 255) : join("", c)])}\""
      : each.value.value
    )
  }]
  ttl = each.value.ttl
}

