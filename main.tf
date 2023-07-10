terraform {
  required_providers {
    oci = {
      source = "oracle/oci"
    }
  }
}

provider "oci" {
  # Configure the OCI provider with your authentication details
  tenancy_ocid     = local.availability_domain
  user_ocid        = local.user_ocid
  fingerprint      = local.fingerprint
  private_key_path = local.private_api_key_path
  region           = local.region
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = local.availability_domain
}

resource "oci_core_instance" "instance2" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = local.availability_domain
  display_name        = "instance2"
  shape               = "VM.Standard.E2.1.Micro"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }
  source_details {
    source_type = "image"
    source_id   = local.ubuntu2204ocid
  }

  metadata = {
    ssh_authorized_keys = local.ssh_pubkey_data
  }
  preserve_boot_volume = false


  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_ocid
  }
}

data "oci_core_vcns" "main_vcns" {
  compartment_id = local.availability_domain
}

resource "oci_core_instance" "instance1" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = local.availability_domain
  display_name        = "instance1"
  shape               = "VM.Standard.E2.1.Micro"
  shape_config {
    ocpus         = 1
    memory_in_gbs = 1
  }
  source_details {
    source_type = "image"
    source_id   = local.ubuntu2204ocid
  }

  metadata = {
    ssh_authorized_keys = local.ssh_pubkey_data
  }
  preserve_boot_volume = false


  create_vnic_details {
    assign_public_ip = true
    subnet_id        = local.subnet_ocid
  }
}

resource "local_file" "ansible_inventory" {
  filename = "ansible/inventory.ini"
  content  = <<-EOT
    [oracl-inst]
    ${oci_core_instance.instance1.display_name} ansible_host=${oci_core_instance.instance1.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${local.ssh_pubkey_path}
    ${oci_core_instance.instance2.display_name} ansible_host=${oci_core_instance.instance2.public_ip} ansible_user=ubuntu ansible_ssh_private_key_file=${local.ssh_pubkey_path}
  EOT
}

#resource "oci_core_security_list" "ssh_security_group" {
#  compartment_id = local.availability_domain
#  vcn_id         = data.oci_core_vcns.main_vcns.virtual_networks[0].id
#  display_name   = "ssh_security_group"

#  ingress_security_rules {
#    protocol = "6"         # TCP
#    source   = "0.0.0.0/0" # Allow access from any IP address
#    tcp_options {
#      min = 22 # SSH port
#      max = 22 # SSH port
#    }
#  }
#}
