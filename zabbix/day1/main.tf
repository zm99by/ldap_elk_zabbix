provider "google" {
  project       = var.project
  region        = var.region
  credentials = "vladimir-project-01-7b7039c36bc6.json"
}

#zabbix server
resource "google_compute_instance" "server" {
    name = "${var.name}-server"
    zone = var.zone
    machine_type = "n1-standard-1"
    description = "zabbix server"
  boot_disk {
    initialize_params {
      image = var.image
      size = var.size
      type = var.disk_type
    }
  }
  metadata_startup_script = templatefile("zabbix.sh", {name = "${var.name}"})
  network_interface {
    network = google_compute_network.vpc.name
    network_ip = google_compute_address.internal_server_address.address
    subnetwork = google_compute_subnetwork.public.name
    access_config {
    }
  }
}

resource "google_compute_instance" "client" {
    name = "${var.name}-client"
    zone = var.zone
    machine_type = "n1-standard-1"
    description = "client and zabbix agent"
  boot_disk {
    initialize_params {
      image = var.image
      size = var.size
      type = var.disk_type
    }
  }
  metadata_startup_script = templatefile("client.sh", {name="${var.name}"})
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork = google_compute_subnetwork.public.name
    access_config {
    }
  }
}


resource "google_compute_network" "vpc" {
  name          = "${var.name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.13.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "internal_all" {
  name    = "${var.name}-internal-fwr"
  network = google_compute_network.vpc.name
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["10.13.1.0/24"]
}

resource "google_compute_firewall" "external" {
  name    = "${var.name}-external-fwr"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "22", "5601", "587", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  description   = "rules for external connections, allows http and ssh"
}

resource "google_compute_address" "internal_server_address" {
  name         = "${var.name}-server-address"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
  region       = var.region
}
