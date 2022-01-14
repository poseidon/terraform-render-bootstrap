# Terraform version and plugin versions

terraform {
  required_version = ">= 0.13.0, < 2.0.0"
  required_providers {
    random = "~> 3.1"
    tls    = "~> 3.1"
  }
}
