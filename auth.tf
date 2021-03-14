locals {
  # component kubeconfigs assets map
  auth_kubeconfigs = {
    "auth/admin.conf" = data.template_file.kubeconfig-admin.rendered,
    "auth/controller-manager.conf" = data.template_file.kubeconfig-controller-manager.rendered,
    "auth/scheduler.conf" = data.template_file.kubeconfig-scheduler.rendered,
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

# Generated kube-controller-manager kubeconfig
data "template_file" "kubeconfig-controller-manager" {
  template = file("${path.module}/resources/kubeconfig-admin")

  vars = {
    name         = var.cluster_name
    ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
    kubelet_cert = base64encode(tls_locally_signed_cert.controller-manager.cert_pem)
    kubelet_key  = base64encode(tls_private_key.controller-manager.private_key_pem)
    server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
  }
}

# Generated kube-controller-manager kubeconfig
data "template_file" "kubeconfig-scheduler" {
  template = file("${path.module}/resources/kubeconfig-admin")

  vars = {
    name         = var.cluster_name
    ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
    kubelet_cert = base64encode(tls_locally_signed_cert.scheduler.cert_pem)
    kubelet_key  = base64encode(tls_private_key.scheduler.private_key_pem)
    server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
  }
}

# Generated kubeconfig to bootstrap Kubelets
data "template_file" "kubeconfig-bootstrap" {
  template = file("${path.module}/resources/kubeconfig-bootstrap")

  vars = {
    ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
    server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
    token_id     = random_password.bootstrap-token-id.result
    token_secret = random_password.bootstrap-token-secret.result
  }
}

# Generate a cryptographically random token id (public)
resource random_password "bootstrap-token-id" {
  length  = 6
  upper   = false
  special = false
}

# Generate a cryptographically random token secret
resource random_password "bootstrap-token-secret" {
  length  = 16
  upper   = false
  special = false
}

