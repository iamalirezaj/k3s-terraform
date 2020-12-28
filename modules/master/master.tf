resource "random_password" "k3s_cluster_secret" {
  length  = 48
  special = false
}

locals {
  root_server_name = keys(var.servers)[0]
  root_server_ip   = values(var.servers)[0].ip
  cluster_token = random_password.k3s_cluster_secret.result
  root_server_connection = {
    type = try(var.servers[local.root_server_name].connection.type, "ssh")

    host     = try(var.servers[local.root_server_name].connection.host, var.servers[local.root_server_name].ip)
    user     = try(var.servers[local.root_server_name].connection.user, null)
    password = try(var.servers[local.root_server_name].connection.password, null)
    port     = try(var.servers[local.root_server_name].connection.port, null)
    timeout  = try(var.servers[local.root_server_name].connection.timeout, null)

    script_path    = try(var.servers[local.root_server_name].connection.script_path, null)
    private_key    = try(var.servers[local.root_server_name].connection.private_key, null)
    certificate    = try(var.servers[local.root_server_name].connection.certificate, null)
    agent          = try(var.servers[local.root_server_name].connection.agent, null)
    agent_identity = try(var.servers[local.root_server_name].connection.agent_identity, null)
    host_key       = try(var.servers[local.root_server_name].connection.host_key, null)

    https    = try(var.servers[local.root_server_name].connection.https, null)
    insecure = try(var.servers[local.root_server_name].connection.insecure, null)
    use_ntlm = try(var.servers[local.root_server_name].connection.use_ntlm, null)
    cacert   = try(var.servers[local.root_server_name].connection.cacert, null)

    bastion_host        = try(var.servers[local.root_server_name].connection.bastion_host, null)
    bastion_host_key    = try(var.servers[local.root_server_name].connection.bastion_host_key, null)
    bastion_port        = try(var.servers[local.root_server_name].connection.bastion_port, null)
    bastion_user        = try(var.servers[local.root_server_name].connection.bastion_user, null)
    bastion_password    = try(var.servers[local.root_server_name].connection.bastion_password, null)
    bastion_private_key = try(var.servers[local.root_server_name].connection.bastion_private_key, null)
    bastion_certificate = try(var.servers[local.root_server_name].connection.bastion_certificate, null)
  }
}

resource "null_resource" "k8s_ca_certificates_install" {
  count = length(local.certificates_files)

  connection {
    type = try(local.root_server_connection.type, "ssh")

    host     = try(local.root_server_connection.host, local.root_server_connection.ip)
    user     = try(local.root_server_connection.user, null)
    password = try(local.root_server_connection.password, null)
    port     = try(local.root_server_connection.port, null)
    timeout  = try(local.root_server_connection.timeout, null)

    script_path    = try(local.root_server_connection.script_path, null)
    private_key    = file(try(local.root_server_connection.private_key, null))
    certificate    = try(local.root_server_connection.certificate, null)
    agent          = try(local.root_server_connection.agent, null)
    agent_identity = try(local.root_server_connection.agent_identity, null)
    host_key       = try(local.root_server_connection.host_key, null)

    https    = try(local.root_server_connection.https, null)
    insecure = try(local.root_server_connection.insecure, null)
    use_ntlm = try(local.root_server_connection.use_ntlm, null)
    cacert   = try(local.root_server_connection.cacert, null)

    bastion_host        = try(local.root_server_connection.bastion_host, null)
    bastion_host_key    = try(local.root_server_connection.bastion_host_key, null)
    bastion_port        = try(local.root_server_connection.bastion_port, null)
    bastion_user        = try(local.root_server_connection.bastion_user, null)
    bastion_password    = try(local.root_server_connection.bastion_password, null)
    bastion_private_key = try(local.root_server_connection.bastion_private_key, null)
    bastion_certificate = try(local.root_server_connection.bastion_certificate, null)
  }

  provisioner "remote-exec" {
    inline = ["mkdir -p /var/lib/rancher/k3s/server/tls/"]
  }

  provisioner "file" {
    content     = local.certificates_files[count.index].file_content
    destination = "/var/lib/rancher/k3s/server/tls/${local.certificates_files[count.index].file_name}"
  }

}

resource "null_resource" "masters_install" {

  depends_on = [null_resource.k8s_ca_certificates_install]

  for_each = var.servers

  // Connection for ssh
  connection {
    type = try(each.value.connection.type, "ssh")

    host     = try(each.value.connection.host, each.value.ip)
    user     = try(each.value.connection.user, null)
    password = try(each.value.connection.password, null)
    port     = try(each.value.connection.port, null)
    timeout  = try(each.value.connection.timeout, null)

    script_path    = try(each.value.connection.script_path, null)
    private_key    = file(try(each.value.connection.private_key, null))
    certificate    = try(each.value.connection.certificate, null)
    agent          = try(each.value.connection.agent, null)
    agent_identity = try(each.value.connection.agent_identity, null)
    host_key       = try(each.value.connection.host_key, null)

    https    = try(each.value.connection.https, null)
    insecure = try(each.value.connection.insecure, null)
    use_ntlm = try(each.value.connection.use_ntlm, null)
    cacert   = try(each.value.connection.cacert, null)

    bastion_host        = try(each.value.connection.bastion_host, null)
    bastion_host_key    = try(each.value.connection.bastion_host_key, null)
    bastion_port        = try(each.value.connection.bastion_port, null)
    bastion_user        = try(each.value.connection.bastion_user, null)
    bastion_password    = try(each.value.connection.bastion_password, null)
    bastion_private_key = try(each.value.connection.bastion_private_key, null)
    bastion_certificate = try(each.value.connection.bastion_certificate, null)
  }

  // Copy K3s service file
  provisioner "file" {
    content     = templatefile("${path.module}/k3s-master.service.tpl", {
      node_name         = each.value.name
      node_external_ip  = each.value.connection.host
      node_internal_ip  = each.value.ip
      cidr_services     = var.cidr.services
      cidr_pods         = var.cidr.pods
      token             = local.cluster_token
      extra_server_args = var.extra_server_args
    })
    destination = "${var.systemd_dir}/k3s-master.service"
  }

  // Enable and check K3s service
  provisioner "remote-exec" {
    inline = [
      "systemctl enable k3s-master && systemctl restart k3s-master"
    ]
  }

  // Wait for node-token
  provisioner "remote-exec" {
    inline = ["until cat /var/lib/rancher/k3s/server/node-token; do sleep 1; done"]
  }

  // Create directory .kube
  provisioner "remote-exec" {
    inline = ["mkdir -p /root/.kube"]
  }

  // Copy config file to user home directory
  provisioner "remote-exec" {
    inline = ["cp /etc/rancher/k3s/k3s.yaml /root/.kube/config"]
  }

  // Replace https://localhost:6443 by https://master-ip:6443
  provisioner "remote-exec" {
    inline = [
      "/usr/local/bin/k3s kubectl config set-cluster default --server=https://${local.root_server_ip}:6443 --kubeconfig /root/.kube/config"
    ]
  }

  // Create kubectl symlink
  provisioner "remote-exec" {
    inline = ["ln -s /usr/local/bin/k3s /usr/local/bin/kubectl"]
  }

  // Create crictl symlink
  provisioner "remote-exec" {
    inline = ["ln -s /usr/local/bin/k3s /usr/local/bin/crictl"]
  }

}
