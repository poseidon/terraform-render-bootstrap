# terraform-render-bootstrap

**Maintainer:** [@bendrucker](https://github.com/bendrucker)

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

Generate the assets.

```sh
terraform init
terraform plan
terraform apply
```

Find bootstrap assets rendered to the `asset_dir` path. That's it.

