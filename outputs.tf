# The "name" of the availability domain to be used for the compute instance.
output "name-of-first-availability-domain" {
  value = data.oci_identity_availability_domains.ads.availability_domains[0]
}

#output "vcn_id" {
#  value = data.oci_core_vcns.main_vcns
#}

output "vm_list" {
  value = [
    for instance in [oci_core_instance.instance1, oci_core_instance.instance2] : {
      hostname   = instance.display_name
      ip_address = instance.public_ip
      user       = "ubuntu"
    }
  ]
}
