variable "extra_agent_args" {
  type = string
  description = "Extra arguments for agent nodes"
  default = ""
}

variable "systemd_dir" {
  type = string
  default = "/etc/systemd/system"
}

variable "token" {
  type = string
  description = "Cluster token that provided by master node"
}

variable "master_ip" {
  type = string
  description = "master node ip address"
}

variable "servers" {
  
  type = map(any)
  description = "agent nodes"

  validation {
    condition     = length(var.servers) > 0
    error_message = "At least one server node must be provided."
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
