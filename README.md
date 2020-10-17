# terraform-render-bootstrap

`terraform-render-bootstrap` is a Terraform module that renders TLS certificates, static pods, and manifests for bootstrapping a Kubernetes cluster.

## Audience

`terraform-render-bootstrap` is a low-level component of the [Typhoon](https://github.com/poseidon/typhoon) Kubernetes distribution. Use Typhoon modules to create and manage Kubernetes clusters across supported platforms. Use the bootstrap module if you'd like to customize a Kubernetes control plane or build your own distribution.

## Usage

Use the module to declare bootstrap assets. Check [variables.tf](variables.tf) for options and [terraform.tfvars.example](terraform.tfvars.example) for examples.

```hcl
module "bootstrap" {
  source = "git::https://github.com/poseidon/terraform-render-bootstrap.git?ref=SHA"

  cluster_name = "example"
  api_servers = ["node1.example.com"]
  etcd_servers = ["node1.example.com"]
}
```

Generate assets in Terraform state.

```sh
terraform init
terraform plan
terraform apply
```

To inspect and write assets locally (e.g. debugging) use the `assets_dist` Terraform output.

```
resource local_file "assets" {
  for_each = module.bootstrap.assets_dist
  filename = "some-assets/${each.key}"
  content = each.value
}
```

