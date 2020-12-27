locals {
  // Use the fetched version if 'lastest' is specified
  k3s_version = var.k3s_version == "latest" ? jsondecode(data.http.k3s_version.body).data[1].latest : var.k3s_version
}

// Fetch the last version of k3s
data "http" "k3s_version" {
  url = "https://update.k3s.io/v1-release/channels"
}

output "k3s_version" {
  value = local.k3s_version
}
