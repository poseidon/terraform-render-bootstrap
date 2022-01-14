locals {
  # component kubeconfigs assets map
  auth_kubeconfigs = {
    "auth/admin.conf"              = local.kubeconfig-admin,
    "auth/controller-manager.conf" = local.kubeconfig-controller-manager
    "auth/scheduler.conf"          = local.kubeconfig-scheduler
  }
}

locals {
  # Generated admin kubeconfig to bootstrap control plane
  kubeconfig-admin = templatefile("${path.module}/resources/kubeconfig-admin",
    {
      name         = var.cluster_name
      ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
      kubelet_cert = base64encode(tls_locally_signed_cert.admin.cert_pem)
      kubelet_key  = base64encode(tls_private_key.admin.private_key_pem)
      server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
    }
  )

  # Generated kube-controller-manager kubeconfig
  kubeconfig-controller-manager = templatefile("${path.module}/resources/kubeconfig-admin",
    {
      name         = var.cluster_name
      ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
      kubelet_cert = base64encode(tls_locally_signed_cert.controller-manager.cert_pem)
      kubelet_key  = base64encode(tls_private_key.controller-manager.private_key_pem)
      server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
    }
  )

  # Generated kube-controller-manager kubeconfig
  kubeconfig-scheduler = templatefile("${path.module}/resources/kubeconfig-admin",
    {
      name         = var.cluster_name
      ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
      kubelet_cert = base64encode(tls_locally_signed_cert.scheduler.cert_pem)
      kubelet_key  = base64encode(tls_private_key.scheduler.private_key_pem)
      server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
    }
  )

  # Generated kubeconfig to bootstrap Kubelets
  kubeconfig-bootstrap = templatefile("${path.module}/resources/kubeconfig-bootstrap",
    {
      ca_cert      = base64encode(tls_self_signed_cert.kube-ca.cert_pem)
      server       = format("https://%s:%s", var.api_servers[0], var.external_apiserver_port)
      token_id     = random_password.bootstrap-token-id.result
      token_secret = random_password.bootstrap-token-secret.result
    }
  )
}

# Generate a cryptographically random token id (public)
resource "random_password" "bootstrap-token-id" {
  length  = 6
  upper   = false
  special = false
}

# Generate a cryptographically random token secret
resource "random_password" "bootstrap-token-secret" {
  length  = 16
  upper   = false
  special = false
}

