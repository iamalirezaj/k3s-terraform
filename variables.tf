variable "k3s_version" {
  type = string
  description = "k3s cluster version"
  default = "latest"
}

variable "install_openebs" {
  type = bool
  description = "Install openebs on k3s cluster"
}

variable "install_minio" {
  type = bool
  description = "Install minio s3 object storage on k3s cluster"
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

variable "master_nodes" {
  
  type = map(any)
  description = "master servers"

  validation {
    condition     = length(var.master_nodes) > 0
    error_message = "At least one server node must be provided."
  }

  validation {
    condition     = length(var.master_nodes) % 2 == 1
    error_message = "Servers must have an odd number of nodes."
  }

  validation {
    condition     = can(values(var.master_nodes)[*].ip)
    error_message = "Field servers.<name>.ip is required."
  }

  validation {
    condition     = !can(values(var.master_nodes)[*].connection) || !contains([for v in var.master_nodes : can(tomap(v.connection))], false)
    error_message = "Field servers.<name>.connection must be a valid Terraform connection."
  }

}

variable "worker_nodes" {
  
  type = map(any)
  description = "worker servers"

  validation {
    condition     = length(var.worker_nodes) > 0
    error_message = "At least one server node must be provided."
  }

  validation {
    condition     = can(values(var.worker_nodes)[*].ip)
    error_message = "Field servers.<name>.ip is required."
  }

  validation {
    condition     = !can(values(var.worker_nodes)[*].connection) || !contains([for v in var.worker_nodes : can(tomap(v.connection))], false)
    error_message = "Field servers.<name>.connection must be a valid Terraform connection."
  }

}
