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

variable subnet_id {
  type        = string
  description = "Subnet"
}

variable service_account_key_file {
  type        = string
  description = "key .json"
}

variable count_app {
  type        = number
  description = "count VMs"
  default     = 1
}

variable app_disk_image {
  type        = string
  description = "Disk image for reddit app"
}
