resource "null_resource" "k3s-prerequisite" {

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

  // Set SELinux to disabled state
  provisioner "remote-exec" {
    inline = ["setenforce 0"]
  }

  // install iSCSI
  provisioner "remote-exec" {
    inline = ["if [ ${var.install_iscsid} = true ]; then yum install iscsi-initiator-utils -y; fi"]
  }

  // enable iSCSI service
  provisioner "remote-exec" {
    inline = ["if [ ${var.install_iscsid} = true ]; then sudo systemctl enable --now iscsid; fi"]
  }

  // Upload k3s file
  provisioner "remote-exec" {
    inline = ["curl -o /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/${local.k3s_version}/k3s -L"]
  }

  // make k3s executable
  provisioner "remote-exec" {
    inline = ["chmod +x /usr/local/bin/k3s"]
  }

}

