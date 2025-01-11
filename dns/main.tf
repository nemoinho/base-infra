resource "hetznerdns_zone" "this" {
  name = var.zone
  ttl  = var.zone_ttl
}

locals {
  records = {
    for record in var.records : "${record.type}#${record.name}#${md5(record.value)}" => {
      for key, value in record : key => value
    }
  }
}

resource "hetznerdns_record" "this" {
  for_each = local.records
  zone_id  = hetznerdns_zone.this.id
  name     = each.value.name
  type     = each.value.type
  value = (each.value.type == "TXT"
    ? "\"${join("\" \"", [for c in chunklist(split("", each.value.value), 255) : join("", c)])}\""
    : each.value.value
  )
  ttl = each.value.ttl
}

