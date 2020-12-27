module "prereq" {
  source = "./modules/prereq"
  k3s_version = var.k3s_version
  servers = merge(var.master_nodes, var.worker_nodes)
}

module "master" {
  source = "./modules/master"
  name = "casty"
  k3s_version = module.prereq.k3s_version
  cidr = var.cidr
  servers = var.master_nodes
  depends_on = [
    module.prereq
  ]
}

module "node" {
  source = "./modules/node"
  servers = var.worker_nodes
  master_ip = module.master.master_ip
  token = module.master.cluster_token

  depends_on = [
    module.master
  ]
}
