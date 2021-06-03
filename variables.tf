#########################################################################################
# IBM Cloud Hyper Protect Crypto Services Provisioning, Initialization and Managing Keys
# Copyright 2020 IBM
#########################################################################################

# Path to which CLOUDTKEFILES has to be exported
variable "tke_files_path" {
  type        = string
  description = "Path to which tke files has to be exported"
}

variable "hpcs_instance_guid" {
  type        = string
  description = "HPCS Instance GUID"
}