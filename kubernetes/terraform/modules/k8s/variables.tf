variable public_key_path {
  description = "Path to the public key used for ssh access"
  type        = string
  default     = "~/.ssh/appuser.pub"
}

variable zone {
  type        = string
  description = "Zone"
  default     = "ru-central1-a"
}

variable count_node {
  type        = number
  description = "count Nodes k8s"
  default     = 1
}

variable service_account_id {
  description = "Service account id"
  type        = string
}
