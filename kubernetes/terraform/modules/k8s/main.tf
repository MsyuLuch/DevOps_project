resource "yandex_kubernetes_cluster" "k8s-zonal" {
  name       = "test-cluster"
  network_id = yandex_vpc_network.k8s-network.id

  master {
    version = "1.23"
    zonal {
      zone      = yandex_vpc_subnet.k8s-subnet.zone
      subnet_id = yandex_vpc_subnet.k8s-subnet.id
    }
    public_ip = true
  }

  service_account_id      = var.service_account_id
  node_service_account_id = var.service_account_id

  release_channel         = "RAPID"
  network_policy_provider = "CALICO"
}

resource "yandex_kubernetes_node_group" "k8s-group" {
  cluster_id = yandex_kubernetes_cluster.k8s-zonal.id
  name       = "k8s-group"
  version    = "1.23"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [yandex_vpc_subnet.k8s-subnet.id]
    }

    resources {
      cores         = 4
      memory        = 16
      core_fraction = 50
    }
    metadata = {
      ssh-keys = "ubuntu:${file(var.public_key_path)}"
    }
  }
  scale_policy {
    fixed_scale {
      size = var.count_node
    }
  }
}

resource "yandex_vpc_network" "k8s-network" {
  name = "k8s-network"
}

resource "yandex_vpc_subnet" "k8s-subnet" {
  zone           = var.zone
  network_id     = yandex_vpc_network.k8s-network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  depends_on = [
    yandex_vpc_network.k8s-network,
  ]
}

resource "yandex_vpc_address" "addr" {
  name = "static-ip"
  external_ipv4_address {
    zone_id = var.zone
  }
}

terraform {
  required_version = "~> 0.12.8"
}
