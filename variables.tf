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
  description = "Choice of networking provider (flannel or cilium)"
  default     = "cilium"
  validation {
    condition     = contains(["flannel", "cilium"], var.networking)
    error_message = "networking can be flannel or cilium."
  }
}

variable "pod_cidr" {
  type        = string
  description = "CIDR IP range to assign Kubernetes pods"
  default     = "10.20.0.0/14"
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
    cilium_agent            = "quay.io/cilium/cilium:v1.18.4"
    cilium_operator         = "quay.io/cilium/operator-generic:v1.18.4"
    coredns                 = "registry.k8s.io/coredns/coredns:v1.13.1"
    flannel                 = "docker.io/flannel/flannel:v0.27.0"
    flannel_cni             = "quay.io/poseidon/flannel-cni:v0.4.2"
    kube_apiserver          = "registry.k8s.io/kube-apiserver:v1.34.2"
    kube_controller_manager = "registry.k8s.io/kube-controller-manager:v1.34.2"
    kube_scheduler          = "registry.k8s.io/kube-scheduler:v1.34.2"
    kube_proxy              = "registry.k8s.io/kube-proxy:v1.34.2"
  }
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
    # CNI providers are enabled for pre-install by default, but only the
    # provider matching var.networking is actually installed.
    flannel = optional(
      object({
        enable = optional(bool, true)
      }),
      {
        enable = true
      }
    )
    cilium = optional(
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
    flannel    = null
    cilium     = null
  }
  # Set the variable value to the default value when the caller
  # sets it to null.
  nullable = false
}

variable "service_account_issuer" {
  type        = string
  description = "kube-apiserver service account token issuer (used as an identifier in 'iss' claims)"
  default     = "https://kubernetes.default.svc.cluster.local"
}
