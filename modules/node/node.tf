resource "null_resource" "nodes_install" {

  for_each = var.servers

  // Connection for ssh
  connection {
    type         = try(each.value.connection.type, "ssh")
    host         = try(each.value.connection.host, each.value.ip)
    user         = try(each.value.connection.user, null)
    password     = try(each.value.connection.password, null)
    port         = try(each.value.connection.port, 22)
    private_key  = file(try(each.value.connection.private_key, null))
  }

  provisioner "local-exec" {
    command = "echo 'setting up node-1'"
  }

  // Copy K3s service file
  provisioner "file" {
    content            = templatefile("${path.module}/k3s-node.service.tpl", {
      node_name        = each.value.name
      node_internal_ip = each.value.ip
      node_external_ip = each.value.connection.host
      master_ip        = var.master_ip
      token            = var.token
      extra_agent_args = var.extra_agent_args
    })
    destination = "${var.systemd_dir}/k3s-node.service"
  }

  // Enable and check K3s service
  provisioner "remote-exec" {
    inline = [
      "systemctl enable k3s-node && systemctl restart k3s-node"
    ]
  }

}
