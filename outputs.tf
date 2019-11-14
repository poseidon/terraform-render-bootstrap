
output "cluster_dns_service_ip" {
  value = cidrhost(var.service_cidr, 10)
}

// Generated kubeconfig for Kubelets (i.e. lower privilege than admin)
output "kubeconfig-kubelet" {
  value = data.template_file.kubeconfig-kubelet.rendered
}

// Generated kubeconfig for admins (i.e. human super-user)
output "kubeconfig-admin" {
  value = data.template_file.kubeconfig-admin.rendered
}

# etcd TLS assets

output "etcd_ca_cert" {
  value = tls_self_signed_cert.etcd-ca.cert_pem
}

output "etcd_client_cert" {
  value = tls_locally_signed_cert.client.cert_pem
}

output "etcd_client_key" {
  value = tls_private_key.client.private_key_pem
}

output "etcd_server_cert" {
  value = tls_locally_signed_cert.server.cert_pem
}

output "etcd_server_key" {
  value = tls_private_key.server.private_key_pem
}

output "etcd_peer_cert" {
  value = tls_locally_signed_cert.peer.cert_pem
}

output "etcd_peer_key" {
  value = tls_private_key.peer.private_key_pem
}
