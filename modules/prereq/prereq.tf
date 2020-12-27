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

  // Enable IPv4 forwarding
  provisioner "remote-exec" {
    inline = ["echo 1 > /proc/sys/net/ipv4/ip_forward"]
  }

  // Enable IPv6 forwarding
  #provisioner "remote-exec" {
    #inline = [""]
  #}

  #// Add br_netfilter to /etc/modules-load.d/ when its centOS
  #provisioner "remote-exec" {
    #inline = ["echo 'br_netfilter' > /etc/modules-load.d/br_netfilter.conf"]
  #}

  #// Load br_netfilter
  #provisioner "remote-exec" {
    #inline = ["modprobe br_netfilter"]
  #}

  #// Set bridge-nf-call-iptables (just to be sure)
  #provisioner "remote-exec" {
    #loop = [
      #"net.bridge.bridge-nf-call-iptables"
      #"net.bridge.bridge-nf-call-ip6tables"
    #]
    #inline = "/sbin/sysctl ${each.loop} -p"
  #}

  // Upload k3s file
  provisioner "remote-exec" {
    inline = ["curl -o /usr/local/bin/k3s https://github.com/k3s-io/k3s/releases/download/${local.k3s_version}/k3s -L"]
  }

  // make k3s executable
  provisioner "remote-exec" {
    inline = ["chmod +x /usr/local/bin/k3s"]
  }

}

