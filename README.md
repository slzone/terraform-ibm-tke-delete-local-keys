# Initialising HPCS Service Instances using Terraform Modules

This is a collection of modules that make it easier to initialise HPCS Instance IBM Cloud Platform:

* [ Download From Cos ](./download-from-cos) - It Downloads input json file from cos bucket.Json File contains Crypto Unit secrets.
* [ Initialisation Automation ](./main.tf) - It takes json file as input to initialise HPCS Instance
* [ Upload TKE Files to COS ](./upload-to-cos) - It Uploads TKE Files to COS Bucket.
* [Remove TKE Files](./remove-tkefiles) - It removes TKE Files and input from local.

## Terraform versions

Terraform 0.13.

## Assumptions to initialize HPCS instance by provided Terraform automation

* To initialize the HPCS instance using the HPCS init module, it is assume that the HPCS instance is being initialized first time after creating the HPCS instance.
* There are no administrators are added and key signatures are created.
* If the HPCS instance was initialized first with script / manually then this auto-init script would not able to initialize the HPCS instance, in this case user would able to run initilaization caommands manually.

## Notes On Initialization
* The current script adds two signature key admins.
* The admin details can be provided in Json trhough localy or through IBM Cloud Object Storage.
* Find the example json [here](./input.json).
* The input file is download from the cos bucket using `download_from_cos` null resource
* Secret TKE Files that are obtained after initialisation can be stored back in the COS Bucket as a Zip File using `upload_to_cos`null resource
* After uploading zip file to COS Bucket all the secret files and input file can be deleted from the local machine using `remove_tke_files` null resource.


## Example usage

* Creating COS bucket is not the part of this Terraform module, but for uploading the signed keys need to create COS bucket as instructed [here](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision#provision-instance).

* Copy the module decleration from [here](./test/stages/stage0.tf) to the main.tf and variables with their values as in [variable example](./test/stages/stage0.tf) variables.tf files and run the terraform.
```hcl
  terraform validate
  terraform init
  terraform plan
  terraform apply
```

## Module and their required input variable details:

### Initialise HPCS instance using json file

* Json file can be downloaded from COS bucket or locally provided as in this examaple [input.json](./input.json) file.

```terraform

module "hpcs_init" {
  initialize = var.initialize
  source     = "git@github.com:slzone/terraform-ibm-hpcs-initialization.git?ref=hpcs-init"
  # source              = "https://github.com/slzone/terraform-ibm-hpcs-initialization"
  hpcs_instance_guid  = var.hpcs_instance_guid
  tke_files_path      = var.tke_files_path
  admin1_name         = var.admin1_name
  admin1_password     = var.admin1_password
  admin2_name         = var.admin2_name
  admin2_password     = var.admin2_password
  admin_num           = var.admin_num
  threshold_value     = var.threshold_value
  rev_threshold_value = var.rev_threshold_value
}

```
### Inputs

| Name              | Description                                                             | Type     | Required |
|-------------------|-------------------------------------------------------------------------|----------|----------|
| initialize        | Flag indicating that if user want to initialize the hpcs.                                               | `bool` | Yes       |
| hpcs_instance_guid| HPCS instance GUID.                                                     | `string` | Yes      |
| tke_files_path    | Path to which tke files has to be exported.                             | `string` | Yes      |
| admin1_name       | First admin name.                                                       | `string` | Yes      |
| admin1_password   | First admin password.                                                   | `string` | Yes      |
| admin2_name       | Second admin name.                                                      | `string` | Yes      |
| admin2_password   | Second admin password.                                                  | `string` | Yes      |
| admin_num         | Number of admins.                                                       | `number` | Yes      |
| threshold_value   | Threshold value.                                                        | `number` | Yes      |
| rev_threshold_value   | Remove / delete threshold value.                                    | `number` | Yes      |

### Upload TKE Files to COS
```terraform
module "upload_to_cos" {
  source = "git::https://github.com/slzone/terraform-ibm-hpcs.git//modules/upload-to-cos?ref=hpcs-init"
  # source             = "git::https://github.com/slzone/terraform-ibm-hpcs.git//modules/upload-to-cos"
  depends_on         = [module.hpcs_init]
  api_key            = var.api_key
  cos_crn            = var.cos_crn
  endpoint           = var.endpoint
  bucket_name        = var.bucket_name
  tke_files_path     = var.tke_files_path
  hpcs_instance_guid = var.hpcs_instance_guid
}
```
### Inputs

| Name              | Description                                                             | Type     | Required |
|-------------------|-------------------------------------------------------------------------|----------|----------|
| api_key           | Api key of the COS bucket.                                              | `string` | Yes      |
| cos_crn           | COS instance CRN.                                                       | `string` | Yes      |
| endpoint          | COS endpoint.                                                           | `string` | Yes      |
| bucket_name       | COS bucket name.                                                        | `string` | Yes      |
| tke_files_path    | Path to which tke files has to be exported.                             | `string` | Yes      |
| hpcs_instance_guid| HPCS Instance GUID.                                                     | `string` | Yes      |


### Remove TKE Files from local machine
`Note:` This module will remove TKE files without having backup.. It is advisable to use this module after uploading TKE Files to COS

```terraform
module "remove_tke_files" {
  # source             = "git::https://github.com/slzone/terraform-ibm-hpcs.git//modules/remove-tkefiles?ref=hpcs-init"
  source             = "git::https://github.com/slzone/terraform-ibm-hpcs.git//modules/remove-tkefiles"
  depends_on         = [module.upload_to_cos]
  tke_files_path     = var.tke_files_path
  input_file_name    = var.input_file_name
  hpcs_instance_guid = var.hpcs_instance_guid
}
```
### Inputs

| Name              | Description                                                             | Type     | Required |
|-------------------|-------------------------------------------------------------------------|----------|----------|
| bucket_name       | COS bucket name.                                                        | `string` | Yes      |
| input_file_name   | Input json file name that is present in the cos-bucket or in the local. | `string` | Yes      |
| tke_files_path    | Path to which tke files has to be exported.                             | `string` | Yes      |
| hpcs_instance_guid| HPCS Instance GUID.                                                     | `string` | Yes      |


### Apply HPCS Network type, Dual deletetion Authorization policy
```terraform
module "hpcs_policies" {
  #   source               = "git::https://github.com/slzone/terraform-ibm-hpcs-initialisation.git//modules/hpcs-policies"
  source               = "git::https://github.com/slzone/terraform-ibm-hpcs-initialisation.git//modules/hpcs-policies?ref=hpcs-init"
  depends_on           = [module.hpcs_init]
  region               = var.region
  resource_group_name  = var.resource_group_name
  service_name         = var.service_name
  hpcs_instance_guid   = var.hpcs_instance_guid
  allowed_network_type = var.allowed_network_type
  hpcs_port            = var.hpcs_port
  dual_auth_delete     = var.dual_auth_delete
}
```
### Inputs

| Name              | Description                                                             | Type     | Required |
|-------------------|-------------------------------------------------------------------------|----------|----------|
| region           | Location of HPCS Instance.                                               | `string` | Yes      |
| service_name           | Name of HPCS Instance.                                             | `string` | Yes      |
| resource_group_name    | CResource group name.                                              | `string` | Yes      |
| allowed_network_type       | Allowed network type.                                          | `string` | Yes      |
| hpcs_port    | HPCS service port number.                                                    | `string` | Yes      |
| dual_auth_delete| Dual auth deletion policy enabled or not.                                                     | `bool` | Yes      |


## Notes for developers

* Clone the repository:
```hcl
  git clone git@github.com:slzone/terraform-ibm-hpcs-initialization.git
```
* python version 3.5 and above: [Installation instructions](https://www.python.org/downloads/)
* pip version 3 and above
```hcl
  python3 -m pip --version
```
* Install pexpect as per instructions [here](https://pexpect.readthedocs.io/en/stable/install.html)
``` hcl 
  pip3 install pexpect
```
`ibm-cos-sdk` package is required if initialisation is performed using objeck storage example..
``` hcl 
  pip3 install ibm-cos-sdk
```
* Login to IBM Cloud Account using cli 
```hcl 
ibmcloud login --apikey `<XXXYourAPIKEYXXXXX>` -r `<region>` -g `<resource_group>`
```
* Generate oauth-tokens `ibmcloud iam oauth-tokens`. This step should be done as and when token expires. 
* To install tke plugin `ibmcloud plugin install tke`. Find more info on tke plugin [here](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-initialize-hsm#initialize-crypto-prerequisites)
* To run locally consider to create virtual environmet as:
```hcl
pip3 install virtualenv
virtualenv venv
virtualenv venv --system-site-packages
source venv/bin/activate
```