locals {
  # auth kubeconfig assets map
  auth_kubeconfigs = {
    "auth/kubeconfig" = data.template_file.kubeconfig-admin.rendered,
  }
}

# Generate a cryptographically random token id (public)
resource random_string "bootstrap-token-id" {
  length  = 6
  upper   = false
  special = false
}

# Generate a cryptographically random token secret
resource random_string "bootstrap-token-secret" {
  length  = 16
  upper   = false
  special = false
}

# Generated kubeconfig to bootstrap Kubelets
data "template_file" "kubeconfig-bootstrap" {
  template = file("${path.module}/resources/kubeconfig-bootstrap")

  vars = {
    ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
    server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
    token_id     = random_string.bootstrap-token-id.result
    token_secret = random_string.bootstrap-token-secret.result
  }
}


# Generated admin kubeconfig to bootstrap control plane
data "template_file" "kubeconfig-admin" {
  template = file("${path.module}/resources/kubeconfig-admin")

  vars = {
    name         = var.cluster_name
    ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
    kubelet_cert = base64encode(tls_locally_signed_cert.admin.cert_pem)
    kubelet_key  = base64encode(tls_private_key.admin.private_key_pem)
    server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
  }
}

# Generated admin kubeconfig to bootstrap control plane
resource "local_file" "kubeconfig-admin" {
  count = var.asset_dir == "" ? 0 : 1

  content  = data.template_file.kubeconfig-admin.rendered
  filename = "${var.asset_dir}/auth/kubeconfig"
}

# Generated admin kubeconfig in a file named after the cluster
resource "local_file" "kubeconfig-admin-named" {
  count = var.asset_dir == "" ? 0 : 1

  content  = data.template_file.kubeconfig-admin.rendered
  filename = "${var.asset_dir}/auth/${var.cluster_name}-config"
}
