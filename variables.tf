variable "cluster_name" {
  description = "Cluster name"
  type        = "string"
}

variable "api_servers" {
  description = "URL used to reach kube-apiserver"
  type        = "list"
}

variable "api_servers_ips" {
  description = "IPs used to reach kube-apiserver."
  type        = "list"
  default     = []
}

variable "etcd_servers" {
  description = "List of etcd server URLs including protocol, host, and port. Ignored if experimental self-hosted etcd is enabled."
  type        = "list"
}

variable "experimental_self_hosted_etcd" {
  description = "(Experimental) Create self-hosted etcd assets"
  default     = false
}

variable "asset_dir" {
  description = "Path to a directory where generated assets should be placed (contains secrets)"
  type        = "string"
}

variable "cloud_provider" {
  description = "The provider for cloud services (empty string for no provider)"
  type        = "string"
  default     = ""
}

variable "pod_cidr" {
  description = "CIDR IP range to assign Kubernetes pods"
  type        = "string"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  description = <<EOD
CIDR IP range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns, the 15th IP will be reserved for self-hosted etcd, and the 20th IP will be reserved for bootstrap self-hosted etcd.
EOD

  type    = "string"
  default = "10.3.0.0/24"
}

variable "container_images" {
  description = "Container images to use"
  type        = "map"

  default = {
    hyperkube = "quay.io/coreos/hyperkube:v1.7.3_coreos.0"
    etcd      = "quay.io/coreos/etcd:v3.1.8"
  }
}

variable "ca_certificate" {
  description = "Existing PEM-encoded CA certificate (generated if blank)"
  type        = "string"
  default     = ""
}

variable "ca_key_alg" {
  description = "Algorithm used to generate ca_key (required if ca_cert is specified)"
  type        = "string"
  default     = "RSA"
}

variable "ca_private_key" {
  description = "Existing Certificate Authority private key (required if ca_certificate is set)"
  type        = "string"
  default     = ""
}
