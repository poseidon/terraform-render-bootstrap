# Terraform version and plugin versions

terraform {
  required_version = ">= 0.12.0, < 0.14.0"
  required_providers {
    random   = "~> 2.2"
    template = "~> 2.1"
    tls      = "~> 2.0"
  }
}
