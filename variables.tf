variable "cluster_name" {
  description = "Cluster name"
  type        = "string"
}

variable "api_servers" {
  description = "List of URLs used to reach kube-apiserver"
  type        = "list"
}

variable "etcd_servers" {
  description = "List of URLs used to reach etcd servers. Ignored if experimental self-hosted etcd is enabled."
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

variable "networking" {
  description = "Choice of networking provider (flannel or calico)"
  type        = "string"
  default     = "flannel"
}

variable "network_mtu" {
  description = "CNI interface MTU (applies to calico only)"
  type        = "string"
  default     = "1500"
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
    calico            = "quay.io/calico/node:v2.6.1"
    calico_cni        = "quay.io/calico/cni:v1.11.0"
    etcd              = "quay.io/coreos/etcd:v3.1.8"
    etcd_operator     = "quay.io/coreos/etcd-operator:v0.5.0"
    etcd_checkpointer = "quay.io/coreos/kenc:0.0.2"
    flannel           = "quay.io/coreos/flannel:v0.9.0-amd64"
    flannel_cni       = "quay.io/coreos/flannel-cni:v0.3.0"
    hyperkube         = "gcr.io/google_containers/hyperkube:v1.8.2"
    kubedns           = "gcr.io/google_containers/k8s-dns-kube-dns-amd64:1.14.5"
    kubedns_dnsmasq   = "gcr.io/google_containers/k8s-dns-dnsmasq-nanny-amd64:1.14.5"
    kubedns_sidecar   = "gcr.io/google_containers/k8s-dns-sidecar-amd64:1.14.5"
    pod_checkpointer  = "quay.io/coreos/pod-checkpointer:ec22bec63334befacc2b237ab73b1a8b95b0a654"
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
