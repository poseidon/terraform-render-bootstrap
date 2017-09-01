# Self-hosted Kubernetes bootstrap-manifests
resource "template_dir" "bootstrap-manifests" {
  source_dir      = "${path.module}/resources/bootstrap-manifests"
  destination_dir = "${var.asset_dir}/bootstrap-manifests"

  vars {
    hyperkube_image = "${var.container_images["hyperkube"]}"
    etcd_servers    = "${var.experimental_self_hosted_etcd ? format("https://%s:2379,https://127.0.0.1:12379", cidrhost(var.service_cidr, 15)) : join(",", formatlist("https://%s:2379", var.etcd_servers))}"

    cloud_provider = "${var.cloud_provider}"
    pod_cidr       = "${var.pod_cidr}"
    service_cidr   = "${var.service_cidr}"
  }
}

# Self-hosted Kubernetes manifests
resource "template_dir" "manifests" {
  source_dir      = "${path.module}/resources/manifests"
  destination_dir = "${var.asset_dir}/manifests"

  vars {
    hyperkube_image = "${var.container_images["hyperkube"]}"
    etcd_servers    = "${var.experimental_self_hosted_etcd ? format("https://%s:2379", cidrhost(var.service_cidr, 15)) : join(",", formatlist("https://%s:2379", var.etcd_servers))}"

    cloud_provider      = "${var.cloud_provider}"
    pod_cidr            = "${var.pod_cidr}"
    service_cidr        = "${var.service_cidr}"
    kube_dns_service_ip = "${cidrhost(var.service_cidr, 10)}"

    ca_cert            = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    apiserver_key      = "${base64encode(tls_private_key.apiserver.private_key_pem)}"
    apiserver_cert     = "${base64encode(tls_locally_signed_cert.apiserver.cert_pem)}"
    serviceaccount_pub = "${base64encode(tls_private_key.service-account.public_key_pem)}"
    serviceaccount_key = "${base64encode(tls_private_key.service-account.private_key_pem)}"

    etcd_ca_cert     = "${base64encode(tls_self_signed_cert.etcd-ca.cert_pem)}"
    etcd_client_cert = "${base64encode(tls_locally_signed_cert.client.cert_pem)}"
    etcd_client_key  = "${base64encode(tls_private_key.client.private_key_pem)}"
  }
}

# Generated kubeconfig
resource "local_file" "kubeconfig" {
  content  = "${data.template_file.kubeconfig.rendered}"
  filename = "${var.asset_dir}/auth/kubeconfig"
}

# Generated kubeconfig with user-context
resource "local_file" "user-kubeconfig" {
  content  = "${data.template_file.user-kubeconfig.rendered}"
  filename = "${var.asset_dir}/auth/${var.cluster_name}-config"
}

data "template_file" "kubeconfig" {
  template = "${file("${path.module}/resources/kubeconfig")}"

  vars {
    ca_cert      = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
    kubelet_key  = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
    server       = "${format("https://%s:443", element(var.api_servers, 0))}"
  }
}

data "template_file" "user-kubeconfig" {
  template = "${file("${path.module}/resources/user-kubeconfig")}"

  vars {
    name         = "${var.cluster_name}"
    ca_cert      = "${base64encode(var.ca_certificate == "" ? join(" ", tls_self_signed_cert.kube-ca.*.cert_pem) : var.ca_certificate)}"
    kubelet_cert = "${base64encode(tls_locally_signed_cert.kubelet.cert_pem)}"
    kubelet_key  = "${base64encode(tls_private_key.kubelet.private_key_pem)}"
    server       = "${format("https://%s:443", element(var.api_servers, 0))}"
  }
}
