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
    subnet_id        = oci_core_subnet.main_subnet.id
    # Security group here to allow incoming connections
    nsg_ids = [oci_core_network_security_group.my_security_group_http.id, ]
  }
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
    subnet_id        = oci_core_subnet.main_subnet.id
    # Security group here to allow incoming connections
    nsg_ids = [oci_core_network_security_group.my_security_group_http.id, ]
  }
}


resource "oci_core_instance" "instance3" {
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  compartment_id      = local.availability_domain
  display_name        = "instance3"
  shape               = "VM.Standard.A1.Flex"
  shape_config {
    ocpus         = 4
    memory_in_gbs = 24
  }
  source_details {
    source_type = "image"
    source_id   = local.ubuntu2204_arm_ocid
  }

  metadata = {
    ssh_authorized_keys = local.ssh_pubkey_data
  }
  preserve_boot_volume = false


  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.main_subnet.id
    # Security group here to allow incoming connections
    nsg_ids = [
      oci_core_network_security_group.my_security_group_http.id,
      oci_core_network_security_group.my_security_group_wg_vpn.id,
    ]
  }
}
