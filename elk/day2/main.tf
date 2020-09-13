provider "google" {
  credentials = "vladimir-project-01-7b7039c36bc6.json"
  project       = var.project
  region        = var.region
}

resource "google_compute_instance" "ek" {
    name = "${var.name}-ek"
    zone = var.zone
    machine_type = "n1-standard-1"
    description = "Centos 7 with elasticsearch and kibana"
  boot_disk {
    initialize_params {
      image = var.image
      size = var.size
      type = var.disk_type
    }
  }
  metadata_startup_script = templatefile("ek.sh", {name = "${var.name}"})
  network_interface {
    network = google_compute_network.vpc.name
    network_ip = google_compute_address.internal_server_address.address
    subnetwork = google_compute_subnetwork.public.name
    access_config {
    }
  }
}

resource "google_compute_instance" "logstash_server" {
    name = "${var.name}-logstash"
    zone = var.zone
    machine_type = "n1-standard-1"
    description = "Centos 7 with Apache Tomcat/7.0.76"
  boot_disk {
    initialize_params {
      image = var.image
      size = var.size
      type = var.disk_type
    }
  }
  metadata_startup_script = templatefile("logstash.sh", {server_ip = "${google_compute_address.internal_server_address.address}"})
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
    protocol = "icmp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "tcp"
  }
  allow {
    ports    = ["0-65535"]
    protocol = "udp"
  }
  source_ranges = ["10.13.1.0/24"]
}

resource "google_compute_firewall" "external" {
  name    = "${var.name}-external-fwr"
  network = google_compute_network.vpc.name
  allow {
    protocol = "tcp"
    ports    = ["80", "22", "5601", "9200", "8080"]
  }
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_address" "internal_server_address" {
  name         = "${var.name}-server-address"
  subnetwork   = google_compute_subnetwork.public.id
  address_type = "INTERNAL"
  region       = var.region
}