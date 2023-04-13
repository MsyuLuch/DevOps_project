variable public_key_path {
  description = "Path to the public key used for ssh access"
  type        = string
  default     = "~/.ssh/appuser.pub"
}

variable app_disk_image {
  description = "Disk image for crawler app"
  type        = string
  default     = "app-base"
}

variable subnet_id {
  description = "Subnets for modules"
  type        = string
}

variable count_app {
  type        = number
  description = "count VMs"
  default     = 1
}
