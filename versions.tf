# Terraform version and plugin versions

terraform {
  required_version = ">= 0.13.0, < 2.0.0"
  required_providers {
    random   = ">= 2.2, < 4"
    template = ">= 2.1, < 4"
    tls      = ">= 2.0, < 4"
  }
}
