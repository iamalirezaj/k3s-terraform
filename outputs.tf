output "kubernetes" {
  value = module.master.kubernetes
  sensitive = true
}

output "kube_config" {
  value = module.master.kube_config
  sensitive = true
}
