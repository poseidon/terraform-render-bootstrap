# bootkube-terraform

`bootkube-terraform` is a Terraform module that renders [bootkube](https://github.com/kubernetes-incubator/bootkube) assets, just like running the binary `bootkube render`. It aims to provide the same variable names, defaults, features, and outputs.

## Status

Warning: This project may move.

TODO:

* Experimental manifests
* etcd TLS
* Self-hosted etcd

## Usage

Use the `bootkube-terraform` module within your existing Terraform configs. See the input `variables.tf` of example `terraform.tfvars.example`.

```hcl
module "bootkube" {
  source = "git://https://github.com/dghubble/bootkube-terraform.git"

  cluster_name = "example"
  api_servers = ["node1.example.com"]
  etcd_servers = ["http://127.0.0.1:2379"]
  output_path = "/home/core/clusters/mycluster"
}
```

Alternately, use a local checkout of this repo and copy `terraform.tfvars.example` to `terraform.tfvars` to generate assets without an existing terraform config repo.

Generate the bootkube assets.

```sh
terraform get
terraform plan
terraform apply
```

### Comparison

Render bootkube assets directly with bootkube v0.4.2.

```sh
bootkube render --asset-dir=assets --api-servers=https://node1.example.com:443 --api-server-alt-names=DNS=node1.example.com --etcd-servers=http://127.0.0.1:2379
```

Compare assets. The only diffs you should see are TLS credentials.

```sh
diff -rw assets /home/core/cluster/mycluster
```
