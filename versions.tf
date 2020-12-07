# Terraform version and plugin versions

terraform {
  required_version = ">= 0.13.0, < 0.15.0"
  required_providers {
    random   = "~> 2.2"
    template = "~> 2.1"
    tls      = "~> 2.0"
  }
}
