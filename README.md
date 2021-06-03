# Remove the local TKE files

It removes TKE Files and input from local.

## Terraform versions

Terraform 0.13.

## Prerequisite

* python version 3.5 and above: [Installation instructions](https://www.python.org/downloads/)

* Login to IBM Cloud Account using cli 

```hcl 
ibmcloud login --apikey `<XXXYourAPIKEYXXXXX>` -r `<region>` -g `<resource_group>`
```

* Generate oauth-tokens `ibmcloud iam oauth-tokens`. This step should be done as and when token expires. 

* To install tke plugin `ibmcloud plugin install tke`. Find more info on tke plugin [here](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-initialize-hsm#initialize-crypto-prerequisites)

## Example usage

### Remove TKE Files from local machine

**Note:** This module will remove TKE files without having backup. It is advisable to use this module after uploading TKE Files to COS

```terraform
module "remove_tke_files" {
  source             = "git::https://github.com/slzone/terraform-ibm-hpcs-initialisation.git//modules/remove-tkefiles"
  tke_files_path     = var.tke_files_path
  hpcs_instance_guid = var.hpcs_instance_guid
}
```

### Inputs

| Name              | Description                                                             | Type     | Required |
|-------------------|-------------------------------------------------------------------------|----------|----------|
| tke_files_path    | Path to which tke files has to be exported.                             | `string` | Yes      |
| hpcs_instance_guid| HPCS Instance GUID.                                                     | `string` | Yes      |

## Notes for developers

* Clone the repository:

```bash
  git clone git@github.com:slzone/terraform-ibm-hpcs-initialization.git
```
