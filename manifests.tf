locals {
  # Kubernetes static pod manifests map
  # {static-manifests/manifest.yaml => content }
  static_manifests = {
    for name in fileset("${path.module}/resources/static-manifests", "*.yaml") :
    "static-manifests/${name}" => templatefile(
      "${path.module}/resources/static-manifests/${name}",
      {
        kube_apiserver_image          = var.container_images["kube_apiserver"]
        kube_controller_manager_image = var.container_images["kube_controller_manager"]
        kube_scheduler_image          = var.container_images["kube_scheduler"]

        etcd_servers      = join(",", formatlist("https://%s:2379", var.etcd_servers))
        pod_cidr          = var.pod_cidr
        service_cidr      = var.service_cidr
        aggregation_flags = var.enable_aggregation ? indent(4, local.aggregation_flags) : ""
      }
    )
  }

  # Kubernetes control plane manifests map
  # { manifests/manifest.yaml => content }
  manifests = merge({
    for name in fileset("${path.module}/resources/manifests", "**/*.yaml") :
    "manifests/${name}" => templatefile(
      "${path.module}/resources/manifests/${name}",
      {
        server         = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
        apiserver_host = var.api_servers[0]
        apiserver_port = var.external_apiserver_port
        token_id       = random_password.bootstrap-token-id.result
        token_secret   = random_password.bootstrap-token-secret.result
      }
    )
    },
    # CoreDNS manifests (optional)
    {
      for name in fileset("${path.module}/resources/coredns", "*.yaml") :
      "manifests/coredns/${name}" => templatefile(
        "${path.module}/resources/coredns/${name}",
        {
          coredns_image          = var.container_images["coredns"]
          control_plane_replicas = max(2, length(var.etcd_servers))
          cluster_domain_suffix  = var.cluster_domain_suffix
          cluster_dns_service_ip = cidrhost(var.service_cidr, 10)
        }
      ) if var.components.enable && var.components.coredns.enable
    },
    # kube-proxy manifests (optional)
    {
      for name in fileset("${path.module}/resources/kube-proxy", "*.yaml") :
      "manifests/kube-proxy/${name}" => templatefile(
        "${path.module}/resources/kube-proxy/${name}",
        {
          kube_proxy_image      = var.container_images["kube_proxy"]
          pod_cidr              = var.pod_cidr
          daemonset_tolerations = var.daemonset_tolerations
        }
      ) if var.components.enable && var.components.kube_proxy.enable
    }
  )
}

locals {
  aggregation_flags = <<EOF

- --proxy-client-cert-file=/etc/kubernetes/pki/aggregation-client.crt
- --proxy-client-key-file=/etc/kubernetes/pki/aggregation-client.key
- --requestheader-client-ca-file=/etc/kubernetes/pki/aggregation-ca.crt
- --requestheader-extra-headers-prefix=X-Remote-Extra-
- --requestheader-group-headers=X-Remote-Group
- --requestheader-username-headers=X-Remote-User
EOF
}

