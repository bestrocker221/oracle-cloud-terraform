####
## MAIN ROUTING
####
resource "oci_core_vcn" "main_vcn" {
  cidr_blocks = [
    "10.0.0.0/16",
  ]
  compartment_id = local.availability_domain
  display_name   = "main-vcn"
  dns_label      = "mainvcn"
  freeform_tags = {
  }
  ipv6private_cidr_blocks = [
  ]
}

resource "oci_core_internet_gateway" "main_vc_Internet-Gateway" {
  compartment_id = local.availability_domain
  display_name   = "Internet Gateway main-vcn"
  enabled        = "true"
  freeform_tags = {
  }
  vcn_id = oci_core_vcn.main_vcn.id
}

resource "oci_core_subnet" "main_subnet" {
  vcn_id         = oci_core_vcn.main_vcn.id
  compartment_id = local.availability_domain
  cidr_block     = "10.0.0.0/24"
  #dhcp_options_id = oci_core_vcn.main_vcns.default_dhcp_options_id
  display_name = "main-subnet"
  dns_label    = "mainsubnet"
  freeform_tags = {
  }

  prohibit_internet_ingress  = "false"
  prohibit_public_ip_on_vnic = "false"

  # we are interested in this, allows SSH default
  security_list_ids = [
    oci_core_vcn.main_vcn.default_security_list_id,
    #oci_core_security_list.https_security_list.id
  ]
}

resource "oci_core_default_route_table" "Default-Route-Table-for-main-vcn" {
  compartment_id = local.availability_domain
  display_name   = "Default Route Table for main-vcn"
  freeform_tags = {
  }
  manage_default_resource_id = oci_core_vcn.main_vcn.default_route_table_id
  route_rules {
    #description = <<Optional value not found in discovery>>
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.main_vc_Internet-Gateway.id
  }
}

## 
## SECURITY GROUPS
## 
resource "oci_core_network_security_group" "my_security_group_http" {
  compartment_id = local.availability_domain
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "my-security-group-http"
}

resource "oci_core_network_security_group" "my_security_group_ssh" {
  compartment_id = local.availability_domain
  vcn_id         = oci_core_vcn.main_vcn.id
  display_name   = "my-security-group-ssh"
}


resource "oci_core_network_security_group" "my_security_group_wg_vpn" {
  compartment_id = local.availability_domain
  display_name   = "my-security-group-wg"
  freeform_tags = {
  }
  vcn_id = oci_core_vcn.main_vcn.id
}

## 
## NSG Rules
## 
resource "oci_core_network_security_group_security_rule" "https_security_rule" {
  network_security_group_id = oci_core_network_security_group.my_security_group_http.id
  direction                 = "INGRESS"
  protocol                  = "6" # TCP
  source                    = "0.0.0.0/0"

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ssh_security_group_rule" {
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.my_security_group_ssh.id
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  tcp_options {
    destination_port_range {
      max = "22"
      min = "22"
    }
    #source_port_range = <<Optional value not found in discovery>>
  }
}


resource "oci_core_network_security_group_security_rule" "wg_security_group_rule" {
  #destination = <<Optional value not found in discovery>>
  destination_type          = ""
  direction                 = "INGRESS"
  network_security_group_id = oci_core_network_security_group.my_security_group_wg_vpn.id
  protocol                  = "17"
  source                    = "0.0.0.0/0"
  source_type               = "CIDR_BLOCK"
  stateless                 = "false"
  udp_options {
    destination_port_range {
      max = "51820"
      min = "51820"
    }
    #source_port_range = <<Optional value not found in discovery>>
  }
}

####
## SECURITY LISTS
####
resource "oci_core_default_security_list" "default-seclist" {
  compartment_id = local.availability_domain
  display_name   = "Default Security List for mainvcn"
  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
    #icmp_options = <<Optional value not found in discovery>>
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  freeform_tags = {
  }
  ingress_security_rules {
    #description = <<Optional value not found in discovery>>
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
      #source_port_range = <<Optional value not found in discovery>>
    }
  }
  ingress_security_rules {
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  ingress_security_rules {
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    #tcp_options = <<Optional value not found in discovery>>
    #udp_options = <<Optional value not found in discovery>>
  }
  manage_default_resource_id = oci_core_vcn.main_vcn.default_security_list_id
  lifecycle {
    create_before_destroy = true
  }
}


# if default open 443 is wanted
#resource "oci_core_security_list" "https_security_list" {
#  compartment_id = local.availability_domain
#  vcn_id         = oci_core_vcn.main_vcn.id
#  display_name   = "https_security_list"

#  ingress_security_rules {
#    protocol = "6"         #TCP
#    source   = "0.0.0.0/0" #Allow access from any IP address
#    tcp_options {
#      min = 443 #https port
#      max = 443 #https port
#    }
#  }
#}
