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
  description = "Choice of networking provider (flannel or calico or cilium or none)"
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
    calico                  = "quay.io/calico/node:v3.27.3"
    calico_cni              = "quay.io/calico/cni:v3.27.3"
    cilium_agent            = "quay.io/cilium/cilium:v1.15.4"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.15.4"
    coredns                 = "registry.k8s.io/coredns/coredns:v1.9.4"
    flannel                 = "docker.io/flannel/flannel:v0.25.1"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.4"
    kube_apiserver          = "registry.k8s.io/kube-apiserver:v1.30.1"
    kube_controller_manager = "registry.k8s.io/kube-controller-manager:v1.30.1"
    kube_scheduler          = "registry.k8s.io/kube-scheduler:v1.30.1"
    kube_proxy              = "registry.k8s.io/kube-proxy:v1.30.1"
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

variable "components" {
  description = "Configure pre-installed cluster components"
  type = object({
    enable = optional(bool, true)
    coredns = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    kube_proxy = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
  })
  default = {
    enable     = true
    coredns    = null
    kube_proxy = null
  }
  # Set the variable value to the default value when the caller
  # sets it to null.
  nullable = false
}
