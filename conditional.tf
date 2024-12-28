# Assets generated only when certain options are chosen

locals {
  # flannel manifests map
  # { manifests-networking/manifest.yaml => content }
  flannel_manifests = {
    for name in fileset("${path.module}/resources/flannel", "*.yaml") :
    "manifests/network/${name}" => templatefile(
      "${path.module}/resources/flannel/${name}",
      {
        flannel_image         = var.container_images["flannel"]
        flannel_cni_image     = var.container_images["flannel_cni"]
        pod_cidr              = var.pod_cidr
        daemonset_tolerations = var.daemonset_tolerations
      }
    )
    if var.components.enable && var.components.flannel.enable && var.networking == "flannel"
  }

  # cilium manifests map
  # { manifests-networking/manifest.yaml => content }
  cilium_manifests = {
    for name in fileset("${path.module}/resources/cilium", "**/*.yaml") :
    "manifests/network/${name}" => templatefile(
      "${path.module}/resources/cilium/${name}",
      {
        cilium_agent_image    = var.container_images["cilium_agent"]
        cilium_operator_image = var.container_images["cilium_operator"]
        pod_cidr              = var.pod_cidr
        daemonset_tolerations = var.daemonset_tolerations
      }
    )
    if var.components.enable && var.components.cilium.enable && var.networking == "cilium"
  }
}

