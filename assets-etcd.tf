# Experimental self-hosted etcd

# etcd pod and service bootstrap-manifests

data "template_file" "bootstrap-etcd" {
  template = "${file("${path.module}/resources/experimental/bootstrap-manifests/bootstrap-etcd.yaml")}"

  vars {
    etcd_image                = "${var.container_images["etcd"]}"
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 200)}"
  }
}

resource "local_file" "bootstrap-etcd" {
  count    = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  content  = "${data.template_file.bootstrap-etcd.rendered}"
  filename = "${var.asset_dir}/experimental/bootstrap-manifests/bootstrap-etcd.yaml"
}

data "template_file" "bootstrap-etcd-service" {
  template = "${file("${path.module}/resources/etcd/bootstrap-etcd-service.json")}"

  vars {
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 200)}"
  }
}

resource "local_file" "bootstrap-etcd-service" {
  count    = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  content  = "${data.template_file.bootstrap-etcd-service.rendered}"
  filename = "${var.asset_dir}/etcd/bootstrap-etcd-service.json"
}

data "template_file" "etcd-tpr" {
  template = "${file("${path.module}/resources/etcd/migrate-etcd-cluster.json")}"

  vars {
    bootstrap_etcd_service_ip = "${cidrhost(var.service_cidr, 200)}"
  }
}

resource "local_file" "etcd-tpr" {
  count    = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  content  = "${data.template_file.etcd-tpr.rendered}"
  filename = "${var.asset_dir}/etcd/migrate-etcd-cluster.json"
}

# etcd operator deployment and service manifests

resource "local_file" "etcd-operator" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  depends_on = ["template_dir.manifests"]

  content  = "${file("${path.module}/resources/experimental/manifests/etcd-operator.yaml")}"
  filename = "${var.asset_dir}/experimental/manifests/etcd-operator.yaml"
}

data "template_file" "etcd-service" {
  template = "${file("${path.module}/resources/experimental/manifests/etcd-service.yaml")}"

  vars {
    etcd_service_ip = "${cidrhost(var.service_cidr, 15)}"
  }
}

resource "local_file" "etcd-service" {
  count      = "${var.experimental_self_hosted_etcd ? 1 : 0}"
  depends_on = ["template_dir.manifests"]

  content  = "${data.template_file.etcd-service.rendered}"
  filename = "${var.asset_dir}/experimental/manifests/etcd-service.yaml"
}
