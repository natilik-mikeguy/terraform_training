nsgs = [
  ######################################
  # nsg1 consists of two rules
  ######################################
  {
    nsg_name = "nsg1"
    nsg_rules = [
      {
        rule_name        = "PermitHTTP"
        rule_priority    = 100
        rule_direction   = "Inbound"
        rule_action      = "Allow"
        rule_proto       = "TCP"
        rule_source_port = "*"
        rule_dest_port   = "80"
        rule_source_addr = "*"
        rule_dest_addr   = "*"
      },
      {
        rule_name        = "PermitSSH"
        rule_priority    = 110
        rule_direction   = "Inbound"
        rule_action      = "Allow"
        rule_proto       = "TCP"
        rule_source_port = "*"
        rule_dest_port   = "22"
        rule_source_addr = "94.4.146.21/32"
        rule_dest_addr   = "*"
      }
    ]
  },


  ######################################
  # nsg2 consists of one rule
  ######################################
  {
    nsg_name = "nsg2"
    nsg_rules = [
      {
        rule_name        = "PermitHTTPS"
        rule_priority    = 100
        rule_direction   = "Inbound"
        rule_action      = "Allow"
        rule_proto       = "TCP"
        rule_source_port = "*"
        rule_dest_port   = "443"
        rule_source_addr = "*"
        rule_dest_addr   = "*"
      }
    ]
  }
]
