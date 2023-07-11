# Terraform for Oracle Cloud Free Tier
Terraform project to create the VMs allowed by the Oracle Cloud Free Tier + Ansible post deployment automation

This repo will deploy:
- default VCN with default subnet
- default port 22 open
- optional security groups for 443, wireguard
- two **VM.Standard.E2.1.Micro** instances allowed by the Oracle free tier. (no need to have billing account)
- one **VM.Standard.A1.Flex** with 24GB RAM, 4 OCPUs allowed by the Oracle free tier. 

All you need is an empty account.

# Steps to deploy
## Step 1. Create API key
```sh
# if you want the password protected key
openssl genrsa -out ~/.ssh/not_ssh_oci_api_key.pem -aes128 2048                    
# if you want the non-password protected key
#openssl genrsa -out ~/.ssh/not_ssh_oci_api_key.pem 2048
chmod go-rwx ~/.ssh/not_ssh_oci_api_key.pem
openssl rsa -pubout -in ~/.ssh/not_ssh_oci_api_key.pem -out ~/.ssh/not_ssh_oci_api_key_public.pem    
```
Or follow here: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm

NOTE: Remember your **user**, **tenancy** and **region** , they will need to go into terraform variables.

Note: **availability_domain** == **tenancy-ocid** == **compartment_id**.

It will save you time I wasted to understand that.


## Step 2.  Add your variables

Create a `variables.tf` file with the necessary information as follow:
```
locals {
  availability_domain  = "ocid1.tenancy.oc..... CHANGEME"
  # this one you can keep
  ubuntu2204ocid       = "ocid1.image.oc1.eu-stockholm-1.aaaaaaaaueqwi7bpc5teyemjxum2eqsy566w4cam3jjsdcgakbwi6zanzwia"
  user_ocid            = "ocid1.user.CHANGEME"
  fingerprint          = "CHANGEME"
  private_api_key_path = pathexpand("~/CHANGEME")
  region               = "CHANGEME"
  ssh_pubkey_path      = pathexpand("~/.ssh/CHANGEME")
  ssh_pubkey_data      = file(pathexpand("~/.ssh/CHANGEME"))
}
```
You can also see your `availability_domain` from: https://cloud.oracle.com/tenancy under **OCID**.




More info on how to gather these ids: https://docs.oracle.com/en-us/iaas/developer-tutorials/tutorials/tf-compute/01-summary.htm

## Step 3. Deploy
```sh
terraform init -upgrade
terraform plan
terraform apply
```


At the end, terraform will generate an ansible inventory file ready for use in `./ansible`


## Note
20GB of storage buckets are free.

## Post deployment?
`cd ansible && ansible-playbook playbook.yml`

Have fun!





## WIP - In case you want to export current setup?

`.terraform/providers/registry.terraform.io/oracle/oci/5.3.0/linux_amd64/terraform-provider-oci_v5.3.0 -command export -compartment_id="ocid1.tenancyCHANGEME" -output_path=./export`
