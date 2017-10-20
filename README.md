# terraform-render-bootkube

`terraform-render-bootkube` is a Terraform module that renders [kubernetes-incubator/bootkube](https://github.com/kubernetes-incubator/bootkube) assets for bootstrapping a Kubernetes cluster.

## Audience

`terraform-render-bootkube` is a low-level component of the [Typhoon](https://github.com/poseidon/typhoon) Kubernetes distribution. Use Typhoon to create and manage Kubernetes clusters across supported platforms. Use the lower-level bootkube module if you'd like to customize a Kubernetes control plane or build your own distribution.

## Usage

Use the module to declare bootkube assets. Check [variables.tf](variables.tf) for options and [terraform.tfvars.example](terraform.tfvars.example) for examples.

```hcl
module "bootkube" {
  source = "git://https://github.com/poseidon/terraform-render-bootkube.git?ref=SHA"

  cluster_name = "example"
  api_servers = ["node1.example.com"]
  etcd_servers = ["node1.example.com"]
  asset_dir = "/home/core/clusters/mycluster"
}
```

Generate the assets.

```sh
terraform init
terraform get --update
terraform plan
terraform apply
```

Find bootkube assets rendered to the `asset_dir` path. That's it.

### Comparison

Render bootkube assets directly with bootkube v0.8.0.

#### On-host etcd (recommended)

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

#### Self-hosted etcd (discouraged)

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

