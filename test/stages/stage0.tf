# Remove tke files from local path
module "remove_tke_files" {
  source             = "git::https://github.com/slzone/terraform-ibm-hpcs-initialisation.git//modules/remove-tkefiles"
  tke_files_path     = var.tke_files_path
  hpcs_instance_guid = var.hpcs_instance_guid
}
