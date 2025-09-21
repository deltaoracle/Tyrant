module "naming" {
  source       = "git::https://dev.azure.com/IXMSA/ixm-iac/_git/ixm-module-naming?ref=main"
  project_name = var.project_name
  environment  = var.environment
  location     = var.location
}