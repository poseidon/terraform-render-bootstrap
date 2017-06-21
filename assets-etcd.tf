# Assets generated only when experimental self-hosted etcd is enabled

# bootstrap-etcd.yaml pod bootstrap-manifest
resource "template_dir" "experimental-bootstrap-manifests" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/bootstrap-manifests"
  destination_dir = "${var.asset_dir}/experimental/bootstrap-manifests"

  vars {
    etcd_image                = "${var.container_images["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd subfolder - bootstrap-etcd-service.json and migrate-etcd-cluster.json TPR
resource "template_dir" "etcd-subfolder" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/etcd"
  destination_dir = "${var.asset_dir}/etcd"

  vars {
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 20)}"
  }
}

# etcd-operator deployment and etcd-service manifests
# etcd member peer, member client, and operator client secrets
resource "template_dir" "experimental-manifests" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  source_dir      = "${path.module}/resources/experimental/manifests"
  destination_dir = "${var.asset_dir}/experimental/manifests"

  vars {
    etcd_service_ip = "${cidrhost(var.service_cidr, 15)}"

    # Self-hosted etcd TLS certs / keys
    etcd_ca_cert = "${base64encode(tls_self_signed_cert.etcd-ca.cert_pem)}"
    etcd_peer_cert = "${base64encode(tls_locally_signed_cert.peer.cert_pem)}"
    etcd_peer_key = "${base64encode(tls_private_key.peer.private_key_pem)}"
    etcd_client_cert = "${base64encode(tls_locally_signed_cert.client.cert_pem)}"
    etcd_client_key = "${base64encode(tls_private_key.client.private_key_pem)}" 
  }
}
