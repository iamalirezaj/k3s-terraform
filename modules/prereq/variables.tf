variable "k3s_version" {
  type = string
  description = "k3s cluster version"
  default = "latest"
}

variable "servers" {
  
  type = map(any)
  description = "all nodes"

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
