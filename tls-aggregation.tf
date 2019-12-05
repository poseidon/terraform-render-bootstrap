locals {
  # Kubernetes Aggregation TLS assets map
  aggregation_tls = var.enable_aggregation ? {
    "tls/k8s/aggregation-ca.crt"     = tls_self_signed_cert.aggregation-ca[0].cert_pem,
    "tls/k8s/aggregation-client.crt" = tls_locally_signed_cert.aggregation-client[0].cert_pem,
    "tls/k8s/aggregation-client.key" = tls_private_key.aggregation-client[0].private_key_pem,
  } : {}
}



# Kubernetes Aggregation CA (i.e. front-proxy-ca)
# Files: tls/{aggregation-ca.crt,aggregation-ca.key}

resource "tls_private_key" "aggregation-ca" {
  count = var.enable_aggregation ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_self_signed_cert" "aggregation-ca" {
  count = var.enable_aggregation ? 1 : 0

  key_algorithm   = tls_private_key.aggregation-ca[0].algorithm
  private_key_pem = tls_private_key.aggregation-ca[0].private_key_pem

  subject {
    common_name = "kubernetes-front-proxy-ca"
  }

  is_ca_certificate     = true
  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing",
  ]
}

resource "local_file" "aggregation-ca-key" {
  count = var.enable_aggregation && var.asset_dir != "" ? 1 : 0

  content  = tls_private_key.aggregation-ca[0].private_key_pem
  filename = "${var.asset_dir}/tls/aggregation-ca.key"
}

resource "local_file" "aggregation-ca-crt" {
  count = var.enable_aggregation && var.asset_dir != "" ? 1 : 0

  content  = tls_self_signed_cert.aggregation-ca[0].cert_pem
  filename = "${var.asset_dir}/tls/aggregation-ca.crt"
}

# Kubernetes apiserver (i.e. front-proxy-client)
# Files: tls/{aggregation-client.crt,aggregation-client.key}

resource "tls_private_key" "aggregation-client" {
  count = var.enable_aggregation ? 1 : 0

  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "tls_cert_request" "aggregation-client" {
  count = var.enable_aggregation ? 1 : 0

  key_algorithm   = tls_private_key.aggregation-client[0].algorithm
  private_key_pem = tls_private_key.aggregation-client[0].private_key_pem

  subject {
    common_name = "kube-apiserver"
  }
}

resource "tls_locally_signed_cert" "aggregation-client" {
  count = var.enable_aggregation ? 1 : 0

  cert_request_pem = tls_cert_request.aggregation-client[0].cert_request_pem

  ca_key_algorithm   = tls_self_signed_cert.aggregation-ca[0].key_algorithm
  ca_private_key_pem = tls_private_key.aggregation-ca[0].private_key_pem
  ca_cert_pem        = tls_self_signed_cert.aggregation-ca[0].cert_pem

  validity_period_hours = 8760

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "client_auth",
  ]
}

resource "local_file" "aggregation-client-key" {
  count = var.enable_aggregation && var.asset_dir != "" ? 1 : 0

  content  = tls_private_key.aggregation-client[0].private_key_pem
  filename = "${var.asset_dir}/tls/aggregation-client.key"
}

resource "local_file" "aggregation-client-crt" {
  count = var.enable_aggregation && var.asset_dir != "" ? 1 : 0

  content  = tls_locally_signed_cert.aggregation-client[0].cert_pem
  filename = "${var.asset_dir}/tls/aggregation-client.crt"
}

