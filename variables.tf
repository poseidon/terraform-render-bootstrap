variable "cluster_name" {
  type        = string
  description = "Cluster name"
}

variable "api_servers" {
  type        = list(string)
  description = "List of URLs used to reach kube-apiserver"
}

variable "etcd_servers" {
  type        = list(string)
  description = "List of URLs used to reach etcd servers."
}

variable "cloud_provider" {
  type        = string
  description = "The provider for cloud services (empty string for no provider)"
  default     = ""
}

variable "networking" {
  type        = string
  description = "Choice of networking provider (flannel or calico or cilium)"
  default     = "flannel"
}

variable "network_mtu" {
  type        = number
  description = "CNI interface MTU (only applies to calico)"
  default     = 1500
}

variable "network_encapsulation" {
  type        = string
  description = "Network encapsulation mode either ipip or vxlan (only applies to calico)"
  default     = "ipip"
}

variable "network_ip_autodetection_method" {
  type        = string
  description = "Method to autodetect the host IPv4 address (only applies to calico)"
  default     = "first-found"
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IP range to assign Kubernetes pods"
  default     = "10.2.0.0/16"
}

variable "service_cidr" {
  type        = string
  description = <<EOD
CIDR IP range to assign Kubernetes services.
The 1st IP will be reserved for kube_apiserver, the 10th IP will be reserved for kube-dns.
EOD
  default     = "10.3.0.0/24"
}


variable "container_images" {
  type        = map(string)
  description = "Container images to use"

  default = {
    calico                  = "quay.io/calico/node:v3.16.5"
    calico_cni              = "quay.io/calico/cni:v3.16.5"
    cilium_agent            = "quay.io/cilium/cilium:v1.9.0"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.9.0"
    coredns                 = "k8s.gcr.io/coredns:1.7.0"
    flannel                 = "quay.io/coreos/flannel:v0.13.0"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.1"
    kube_apiserver          = "k8s.gcr.io/kube-apiserver:v1.19.4"
    kube_controller_manager = "k8s.gcr.io/kube-controller-manager:v1.19.4"
    kube_scheduler          = "k8s.gcr.io/kube-scheduler:v1.19.4"
    kube_proxy              = "k8s.gcr.io/kube-proxy:v1.19.4"
  }
}


variable "trusted_certs_dir" {
  type        = string
  description = "Path to the directory on cluster nodes where trust TLS certs are kept"
  default     = "/usr/share/ca-certificates"
}

variable "enable_reporting" {
  type        = bool
  description = "Enable usage or analytics reporting to upstream component owners (Tigera: Calico)"
  default     = false
}

variable "enable_aggregation" {
  type        = bool
  description = "Enable the Kubernetes Aggregation Layer (defaults to false, recommended)"
  default     = false
}

# unofficial, temporary, may be removed without notice

variable "external_apiserver_port" {
  type        = number
  description = "External kube-apiserver port (e.g. 6443 to match internal kube-apiserver port)"
  default     = 6443
}

variable "cluster_domain_suffix" {
  type        = string
  description = "Queries for domains with the suffix will be answered by kube-dns"
  default     = "cluster.local"
}

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
}

