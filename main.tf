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

