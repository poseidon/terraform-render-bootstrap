# bootkube-terraform

`bootkube-terraform` is a Terraform module that renders [bootkube](https://github.com/kubernetes-incubator/bootkube) assets, just like running the binary `bootkube render`. It aims to provide the same variable names, defaults, features, and outputs.

## Usage

Use the `bootkube-terraform` module within your existing Terraform configs. Provide the variables listed in `variables.tf` or check `terraform.tfvars.example` for examples.

```hcl
module "bootkube" {
  source = "git://https://github.com/dghubble/bootkube-terraform.git?ref=SHA"

  cluster_name = "example"
  api_servers = ["node1.example.com"]
  etcd_servers = ["node1.example.com"]
  asset_dir = "/home/core/clusters/mycluster"
  experimental_self_hosted_etcd = false
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

Render bootkube assets directly with bootkube v0.4.5.

#### On-host etcd

```sh
bootkube render --asset-dir=assets --api-servers=https://node1.example.com:443 --api-server-alt-names=DNS=node1.example.com --etcd-servers=https://node1.example.com:2379
```

Compare assets. The only diffs you should see are TLS credentials.

```sh
diff -rw assets /home/core/mycluster
```

#### Self-hosted etcd

```sh
bootkube render --asset-dir=assets --api-servers=https://node1.example.com:443 --api-server-alt-names=DNS=node1.example.com --experimental-self-hosted-etcd
```

Compare assets. Note that experimental must be generated to a separate directory for terraform applies to sync. Move the experimental `bootstrap-manifests` and `manifests` files during deployment.

```sh
pushd /home/core/mycluster
mv experimental/bootstrap-manifests/* boostrap-manifests
mv experimental/manifests/* manifests
popd
diff -rw assets /home/core/mycluster
```

