#resource "kubernetes_namespace" "openebs" {
  #metadata {
    #name = "openebs"
  #}
  #depends_on     = [
    #module.node,
    #var.install_openebs
  #]
#}
#resource "helm_release" "openebs" {
  #name           = "openebs"
  #namespace      = "openebs"
  #repository     = "https://openebs.github.io/charts"
  #chart          = "openebs"
  #values         = [file("${path.module}/resources/openebs_values.yaml")]
  #depends_on     = [
    #kubernetes_namespace.openebs
  #]
#}

