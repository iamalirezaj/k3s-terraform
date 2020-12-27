variable "extra_server_args" {
  type = string
  description = "Extra arguments for master nodes"
  default = ""
}

variable "k3s_version" {
  type = string
  default = "latest"
}

variable "generate_ca_certificates" {
  type = bool
  default = true
}

variable "name" {
  type = string
  description = "Cluster name"
}

variable "kubernetes_certificates" {
  description = "A list of maps of cerificate-name.[crt/key] : cerficate-value to copied to /var/lib/rancher/k3s/server/tls, if this option is used generate_ca_certificates will be treat as false"
  type = list(
    object({
      file_name    = string,
      file_content = string
    })
  )
  default = []
}

variable "systemd_dir" {
  type = string
  default = "/etc/systemd/system"
}

variable "cidr" {
  type = object({
    pods = string
    services = string
  })
  description = "Cidr"
  default = {
    pods = "10.42.0.0/16"
    services = "10.43.0.0/16"
  }
}

variable "servers" {
  
  type = map(any)
  description = "master nodes"

  validation {
    condition     = length(var.servers) > 0
    error_message = "At least one server node must be provided."
  }

  validation {
    condition     = length(var.servers) % 2 == 1
    error_message = "Servers must have an odd number of nodes."
  }

  validation {
    condition     = can(values(var.servers)[*].ip)
    error_message = "Field servers.<name>.ip is required."
  }

  validation {
    condition     = !can(values(var.servers)[*].connection) || !contains([for v in var.servers : can(tomap(v.connection))], false)
    error_message = "Field servers.<name>.connection must be a valid Terraform connection."
  }

}
