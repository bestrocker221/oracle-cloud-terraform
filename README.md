# Terraform for Oracle Cloud Free Tier
Terraform project to create the VMs allowed by the Oracle Cloud Free Tier + Ansible post deployment automation

This repo will deploy two **VM.Standard.E2.1.Micro** instances allowed by the Oracle free tier. (no need to have billing account)

# Steps to deploy
## Step 1. Create API key
```sh
# if you want the password protected key
openssl genrsa -out ~/.oci/oci_api_key.pem -aes128 2048                    
# if you want the non-password protected key
#openssl genrsa -out ~/.ssh/not_ssh_oci_api_key.pem 2048
chmod go-rwx ~/.ssh/not_ssh_oci_api_key.pem
openssl rsa -pubout -in /home/bsod/.ssh/not_ssh_oci_api_key.pem -out /home/bsod/.ssh/not_ssh_oci_api_key_public.pem    
```
Or follow here: https://docs.oracle.com/en-us/iaas/Content/API/Concepts/apisigningkey.htm

## Step 2.  Add your variables

Create a `variables.tf` file with the necessary information as follow:
```
locals {
  availability_domain  = "ocid1.tenancy.oc..... CHANGEME"
  subnet_ocid          = "ocid1.subnet.oc1..... CHANGEME"
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

## Step 3. Deploy
```sh
terraform init -upgrade
terraform plan
terraform apply
```

At the end, terraform will generate an ansible inventory file ready for use in `./ansible`

## Post deployment?
`cd ansible && ansible-playbook playbook.yml`




