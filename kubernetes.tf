provider "kubernetes" {
  load_config_file       = "false"
  host                   = module.master.kubernetes.api_endpoint
  client_certificate     = module.master.kubernetes.client_certificate
  client_key             = module.master.kubernetes.client_key
  cluster_ca_certificate = module.master.kubernetes.cluster_ca_certificate
}

