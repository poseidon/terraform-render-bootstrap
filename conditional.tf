# Assets generated only when experimental self-hosted etcd is enabled

resource "template_dir" "flannel-manifests" {
  count           = "${var.networking == "flannel" ? 1 : 0}"
  source_dir      = "${path.module}/resources/flannel"
  destination_dir = "${var.asset_dir}/manifests-networking"

  vars {
    flannel_image     = "${var.container_images["flannel"]}"
    flannel_cni_image = "${var.container_images["flannel_cni"]}"

    pod_cidr = "${var.pod_cidr}"
  }
}

resource "template_dir" "calico-manifests" {
  count           = "${var.networking == "calico" ? 1 : 0}"
  source_dir      = "${path.module}/resources/calico"
  destination_dir = "${var.asset_dir}/manifests-networking"

  vars {
    calico_image     = "${var.container_images["calico"]}"
    calico_cni_image = "${var.container_images["calico_cni"]}"

    network_mtu = "${var.network_mtu}"
    pod_cidr    = "${var.pod_cidr}"
  }
}

# bootstrap-etcd.yaml pod bootstrap-manifest
resource "template_dir" "experimental-bootstrap-manifests" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/bootstrap-manifests"
  destination_dir = "${var.asset_dir}/experimental/bootstrap-manifests"

  vars {
    etcd_image                = "${var.container_images["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd subfolder - bootstrap-etcd-service.json and migrate-etcd-cluster.json TPR
resource "template_dir" "etcd-subfolder" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/etcd"
  destination_dir = "${var.asset_dir}/etcd"

  vars {
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd-operator deployment and etcd-service manifests
# etcd client, server, and peer tls secrets
resource "template_dir" "experimental-manifests" {
  count           = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/manifests"
  destination_dir = "${var.asset_dir}/experimental/manifests"

  vars {
    etcd_operator_image     = "${var.container_images["etcd_operator"]}"
    etcd_checkpointer_image = "${var.container_images["etcd_checkpointer"]}"
    etcd_service_ip         = "${cidrhost(var.service_cidr, 15)}"

    # Self-hosted etcd TLS certs / keys
    etcd_ca_cert     = "${base64encode(tls_self_signed_cert.etcd-ca.cert_pem)}"
    etcd_client_cert = "${base64encode(tls_locally_signed_cert.client.cert_pem)}"
    etcd_client_key  = "${base64encode(tls_private_key.client.private_key_pem)}"
    etcd_server_cert = "${base64encode(tls_locally_signed_cert.server.cert_pem)}"
    etcd_server_key  = "${base64encode(tls_private_key.server.private_key_pem)}"
    etcd_peer_cert   = "${base64encode(tls_locally_signed_cert.peer.cert_pem)}"
    etcd_peer_key    = "${base64encode(tls_private_key.peer.private_key_pem)}"
  }
}
