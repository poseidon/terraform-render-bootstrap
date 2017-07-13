output "id" {
  value = "${sha1("${template_dir.bootstrap-manifests.id} ${local_file.kubeconfig.id}")}"
}

output "content_hash" {
  value = "${sha1("${template_dir.bootstrap-manifests.id} ${template_dir.manifests.id}")}"
}

output "kube_dns_service_ip" {
  value = "${cidrhost(var.service_cidr, 10)}"
}

output "etcd_service_ip" {
  value = "${cidrhost(var.service_cidr, 15)}"
}

output "kubeconfig" {
  value = "${data.template_file.kubeconfig.rendered}"
}

output "user-kubeconfig" {
  value = "${local_file.user-kubeconfig.filename}"
}

# etcd TLS assets

output "etcd_ca_cert" {
  value = "${tls_self_signed_cert.etcd-ca.cert_pem}"
}

output "etcd_client_cert" {
  value = "${tls_locally_signed_cert.client.cert_pem}"
}

output "etcd_client_key" {
  value = "${tls_private_key.client.private_key_pem}"
}

output "etcd_server_cert" {
  value = "${tls_locally_signed_cert.server.cert_pem}"
}

output "etcd_server_key" {
  value = "${tls_private_key.server.private_key_pem}"
}

output "etcd_peer_cert" {
  value = "${tls_locally_signed_cert.peer.cert_pem}"
}

output "etcd_peer_key" {
  value = "${tls_private_key.peer.private_key_pem}"
}

# Some platforms may need to reconstruct the kubeconfig directly in user-data.
# That can't be done with the way template_file interpolates multi-line
# contents so the raw components of the kubeconfig may be needed.

output "ca_cert" {
  value = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
}

output "kubelet_cert" {
  value = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
}

output "kubelet_key" {
  value = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
}

output "server" {
  value = "${format("https://%s:443", element(var.api_servers, 0))}"
}
