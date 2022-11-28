locals {
  # Kubernetes TLS assets map
  kubernetes_tls = {
    "tls/k8s/ca.crt"              = tls_self_signed_cert.kube-ca.cert_pem,
    "tls/k8s/ca.key"              = tls_private_key.kube-ca.private_key_pem,
    "tls/k8s/apiserver.crt"       = tls_locally_signed_cert.apiserver.cert_pem,
    "tls/k8s/apiserver.key"       = tls_private_key.apiserver.private_key_pem,
    "tls/k8s/service-account.pub" = tls_private_key.service-account.public_key_pem
    "tls/k8s/service-account.key" = tls_private_key.service-account.private_key_pem
  }
}

# Kubernetes CA (tls/{ca.crt,ca.key})

resource "tls_private_key" "kube-ca" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "kube-ca" {
  private_key_pem = tls_private_key.kube-ca.private_key_pem

  subject {
    common_name  = "kubernetes-ca"
    organization = "typhoon"
  }

  is_ca_certificate     = true
  validity_period_hours = var.certificates_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

# Kubernetes API Server (tls/{apiserver.key,apiserver.crt})

resource "tls_private_key" "apiserver" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "apiserver" {
  private_key_pem = tls_private_key.apiserver.private_key_pem

  subject {
    common_name  = "kube-apiserver"
    organization = "system:masters"
  }

  dns_names = flatten([
    var.api_servers,
    "kubernetes",
    "kubernetes.default",
    "kubernetes.default.svc",
    "kubernetes.default.svc.${var.cluster_domain_suffix}",
  ])

  ip_addresses = [
    cidrhost(var.service_cidr, 1),
  ]
}

resource "tls_locally_signed_cert" "apiserver" {
  cert_request_pem = tls_cert_request.apiserver.cert_request_pem

  ca_private_key_pem = tls_private_key.kube-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube-ca.cert_pem

  validity_period_hours = var.certificates_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
    "client_auth",
  ]
}

# kube-controller-manager

resource "tls_private_key" "controller-manager" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "controller-manager" {
  private_key_pem = tls_private_key.controller-manager.private_key_pem

  subject {
    common_name = "system:kube-controller-manager"
  }
}

resource "tls_locally_signed_cert" "controller-manager" {
  cert_request_pem = tls_cert_request.controller-manager.cert_request_pem

  ca_private_key_pem = tls_private_key.kube-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube-ca.cert_pem

  validity_period_hours = var.certificates_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# kube-scheduler

resource "tls_private_key" "scheduler" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "scheduler" {
  private_key_pem = tls_private_key.scheduler.private_key_pem

  subject {
    common_name = "system:kube-scheduler"
  }
}

resource "tls_locally_signed_cert" "scheduler" {
  cert_request_pem = tls_cert_request.scheduler.cert_request_pem

  ca_private_key_pem = tls_private_key.kube-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube-ca.cert_pem

  validity_period_hours = var.certificates_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# Kubernetes Admin (tls/{admin.key,admin.crt})

resource "tls_private_key" "admin" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "admin" {
  private_key_pem = tls_private_key.admin.private_key_pem

  subject {
    common_name  = "kubernetes-admin"
    organization = "system:masters"
  }
}

resource "tls_locally_signed_cert" "admin" {
  cert_request_pem = tls_cert_request.admin.cert_request_pem

  ca_private_key_pem = tls_private_key.kube-ca.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.kube-ca.cert_pem

  validity_period_hours = var.certificates_validity_period

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

# Kubernete's Service Account (tls/{service-account.key,service-account.pub})

resource "tls_private_key" "service-account" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

