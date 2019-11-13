locals {
  # Kubernetes static pod manifests (manifest.yaml => content)
  static_manifests = {
    for name in fileset("${path.module}/resources/static-manifests", "*.yaml"):
    "static-manifests/${name}" => templatefile(
      "${path.module}/resources/static-manifests/${name}",
      {
        hyperkube_image   = var.container_images["hyperkube"]
        etcd_servers      = join(",", formatlist("https://%s:2379", var.etcd_servers))
        cloud_provider    = var.cloud_provider
        pod_cidr          = var.pod_cidr
        service_cidr      = var.service_cidr
        trusted_certs_dir = var.trusted_certs_dir
        aggregation_flags = var.enable_aggregation ? indent(4, local.aggregation_flags) : ""
      }
    )
  }

  # Kubernetes control plane manifests (manifest.yaml => content)
  manifests = {
    for name in fileset("${path.module}/resources/manifests", "**/*.yaml"):
    "manifests/${name}" => templatefile(
      "${path.module}/resources/manifests/${name}",
      {
        hyperkube_image        = var.container_images["hyperkube"]
        coredns_image          = var.container_images["coredns"]
        control_plane_replicas = max(2, length(var.etcd_servers))
        pod_cidr               = var.pod_cidr
        cluster_domain_suffix  = var.cluster_domain_suffix
        cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
        trusted_certs_dir      = var.trusted_certs_dir
        server                 = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
      }
    )
  }
}

# Kubernetes static pod manifests
resource "local_file" "static-manifests" {
  for_each = local.static_manifests

  content  = each.value
  filename = "${var.asset_dir}/${each.key}"
}

# Kubernetes control plane manifests
resource "local_file" "manifests" {
  for_each = local.manifests

  content  = each.value
  filename = "${var.asset_dir}/${each.key}"
}

locals {
  aggregation_flags = <<EOF

- --proxy-client-cert-file=/etc/kubernetes/secrets/aggregation-client.crt
- --proxy-client-key-file=/etc/kubernetes/secrets/aggregation-client.key
- --requestheader-client-ca-file=/etc/kubernetes/secrets/aggregation-ca.crt
- --requestheader-extra-headers-prefix=X-Remote-Extra-
- --requestheader-group-headers=X-Remote-Group
- --requestheader-username-headers=X-Remote-User
EOF
}

