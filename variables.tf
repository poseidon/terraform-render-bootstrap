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

# optional

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
    calico                  = "quay.io/calico/node:v3.24.5"
    calico_cni              = "quay.io/calico/cni:v3.24.5"
    cilium_agent            = "quay.io/cilium/cilium:v1.12.4"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.12.4"
    coredns                 = "registry.k8s.io/coredns/coredns:v1.9.3"
    flannel                 = "docker.io/flannelcni/flannel:v0.20.1"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.2"
    kube_apiserver          = "registry.k8s.io/kube-apiserver:v1.25.4"
    kube_controller_manager = "registry.k8s.io/kube-controller-manager:v1.25.4"
    kube_scheduler          = "registry.k8s.io/kube-scheduler:v1.25.4"
    kube_proxy              = "registry.k8s.io/kube-proxy:v1.25.4"
  }
}

variable "enable_reporting" {
  type        = bool
  description = "Enable usage or analytics reporting to upstream component owners (Tigera: Calico)"
  default     = false
}

variable "enable_aggregation" {
  type        = bool
  description = "Enable the Kubernetes Aggregation Layer (defaults to true)"
  default     = true
}

variable "daemonset_tolerations" {
  type        = list(string)
  description = "List of additional taint keys kube-system DaemonSets should tolerate (e.g. ['custom-role', 'gpu-role'])"
  default     = []
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

variable "certificates_validity_period" {
  type = number
  default = 8760
  description = "Validity in hours for kubernetes certificates"
}