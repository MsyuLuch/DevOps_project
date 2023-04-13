resource "yandex_compute_instance" "app" {

  name  = "crawler-app${count.index + 1}"
  count = var.count_app

  labels = {
    tags = "crawler-app"
  }

  resources {
    cores  = 2
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.app_disk_image
    }
  }

  network_interface {
    subnet_id = var.subnet_id
    nat       = true
  }

  metadata = {
    ssh-keys           = "ubuntu:${file(var.public_key_path)}"
    serial-port-enable = 1
  }
}
