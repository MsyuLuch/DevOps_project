variable cloud_id {
  type        = string
  description = "Cloud"
}

variable folder_id {
  type        = string
  description = "Folder"
}

variable zone {
  type        = string
  description = "Zone"
  default     = "ru-central1-a"
}

variable public_key_path {
  type        = string
  description = "Path to the public key used for ssh access"
}

variable service_account_key_file {
  type        = string
  description = "key .json"
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
