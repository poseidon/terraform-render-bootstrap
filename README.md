# bootkube-terraform

`bootkube-terraform` is Terraform module that renders [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube) bootstrapping assets. It functions as a low-level component of the [Typhoon](https://github.com/poseidon/typhoon) Kubernetes distribution.

The module provides many of the same variable names, defaults, features, and outputs as running `bootkube render` directly.

## Usage

Use [Typhoon](https://github.com/poseidon/typhoon) to create and manage Kubernetes clusters in different environments. Use `bootkube-terraform` if you require low-level customizations to the control plane or wish to build your own distribution.

Add the `bootkube-terraform` module alongside existing Terraform configs. Provide the variables listed in `variables.tf` or check `terraform.tfvars.example` for examples.

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

Render bootkube assets directly with bootkube v0.6.2.

#### On-host etcd

```sh
bootkube render --asset-dir=assets --api-servers=https://node1.example.com:443 --api-server-alt-names=DNS=node1.example.com --etcd-servers=https://node1.example.com:2379
```

Compare assets. The only diffs you should see are TLS credentials.

```sh
pushd /home/core/mycluster
mv manifests-networking/* manifests
popd
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
mv manifests-networking/* manifests
popd
diff -rw assets /home/core/mycluster
```

