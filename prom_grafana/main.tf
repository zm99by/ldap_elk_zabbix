provider "google" {
  credentials = "vladimir-project-01-7b7039c36bc6.json"
  project       = var.project 
  region        = var.region
  zone          = var.zone
}

resource "google_compute_firewall" "grafana" {
  name           = "grafana"
  network        = "default"
  allow {
    protocol     = "tcp"
    ports        = ["9090","9100","3000","9115"]
  }
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["grafana"]
}

resource "google_compute_firewall" "exporter" {
  name           = "exporter"
  network        = "default"
  allow {
    protocol     = "tcp"
    ports        = ["9100"]
  }
  source_ranges  = ["0.0.0.0/0"]
  target_tags    = ["exporter"]
}

resource "google_compute_instance" "prometheus" {
  name         = "prometheus"
  machine_type = "n1-standard-1"
  tags         = ["grafana"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
  
  metadata_startup_script = templatefile("prometheus.sh", { 
    IP  = "${local.remote}" }) 
  
  network_interface {
    network    = "default"
    access_config {
    }
  }
}

resource "google_compute_instance" "exporter" {
  name         = "exporter"
  machine_type = "n1-standard-1"
  tags         = ["exporter"]
  boot_disk {
    initialize_params {
      image    = "centos-cloud/centos-7"
    }
  }
 
  metadata_startup_script = file("exporter.sh")

  network_interface {
    network    = "default"
    access_config {
    }
  }
}

locals {
  remote = google_compute_instance.exporter.network_interface.0.network_ip
}

