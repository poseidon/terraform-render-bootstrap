# Experimental self-hosted etcd

# Bootstrap etcd pod

data "template_file" "bootstrap-etcd" {
  template = "${file("${path.module}/resources/experimental/bootstrap-manifests/bootstrap-etcd.yaml")}"
  vars {
    etcd_image = "${var.container_images["etcd"]}"
  }
}

resource "local_file" "bootstrap-etcd" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  content  = "${data.template_file.bootstrap-etcd.rendered}"
  filename = "${var.asset_dir}/experimental/bootstrap-manifests/bootstrap-etcd.yaml"
}

# etcd operator deployment and etcd service

resource "local_file" "etcd-operator" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  depends_on = ["template_dir.manifests"]

  content  = "${file("${path.module}/resources/experimental/manifests/etcd-operator.yaml")}"
  filename = "${var.asset_dir}/experimental/manifests/etcd-operator.yaml"
}

data "template_file" "etcd-service" {
  template = "${file("${path.module}/resources/experimental/manifests/etcd-service.yaml")}"
  vars {
    etcd_service_ip = "${var.kube_etcd_service_ip}"
  }
}

resource "local_file" "etcd-service" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  depends_on = ["template_dir.manifests"]

  content  = "${data.template_file.etcd-service.rendered}"
  filename = "${var.asset_dir}/experimental/manifests/etcd-service.yaml"
}
