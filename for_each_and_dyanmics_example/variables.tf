variable "nsgs" {
  type = list(object({
    nsg_name = string
    nsg_rules = list(object({
      rule_name        = string
      rule_priority    = number
      rule_direction   = string
      rule_action      = string
      rule_proto       = string
      rule_source_port = string
      rule_dest_port   = string
      rule_source_addr = string
      rule_dest_addr   = string
    }))
  }))
}
