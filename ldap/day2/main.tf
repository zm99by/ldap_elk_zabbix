#
provider "google" {
  credentials = "vladimir-project-01-7b7039c36bc6.json"
  project                 = var.project
  region                  = var.region
  zone 		                = var.zone
}

resource "google_compute_network" "vpc_ldap" {
  name                    = "${var.name}-ldap-vpc"
  auto_create_subnetworks = var.vpc_ldap_auto_subnetworks
}

resource "google_compute_subnetwork" "subnetwork_ldap" {
  name                    = "${var.name}-subnetwork-ldap"
  ip_cidr_range           = var.subnetwork_ldap_ip_cidr_range
  network                 = google_compute_network.vpc_ldap.id
}

resource "google_compute_instance" "vm-server" {
  name                    = "${var.name}-vm-server"
  machine_type            = var.wm_machine_type
  tags                    = var.wm_tags
  metadata = {
  # ssh-keys              = "${var.ssh_user}:${file(var.ssh_key)}"
  }

  boot_disk {
    initialize_params {
      image               = var.wm_image
    }
  }

  network_interface {
    network               = google_compute_network.vpc_ldap.name
    network_ip            = google_compute_address.default.address
    subnetwork            = google_compute_subnetwork.subnetwork_ldap.name

    access_config {
      
    }
  }
  
  metadata_startup_script = file("install.sh")
}

resource "google_compute_instance" "vm-client" {
  name                    = "${var.name}-vm-client"
  machine_type            = var.wm_machine_type
  tags                    = var.wm_tags
  
  boot_disk {
    initialize_params {
      image               = var.wm_image
    }
  }

  network_interface {
    network               = google_compute_network.vpc_ldap.name
    subnetwork            = google_compute_subnetwork.subnetwork_ldap.name

    access_config {
      
    }
  }
  metadata_startup_script = templatefile("installcl.sh", {Address = "${google_compute_address.default.address}"})

  depends_on    = [google_compute_instance.vm-server]

}

resource "google_compute_firewall" "firewall_ldap_server" {
  name                    = "${var.name}-firewall-ldap-server"
  network                 = google_compute_network.vpc_ldap.name
  source_ranges           = var.firewall_ldap_server_source_ranges

  allow {
    protocol              = var.firewall_ldap_server_protocol
    ports                 = var.firewall_ldap_server_ports
  }
  allow {
    protocol = "icmp"
  }

  source_tags             = var.wm_tags
}

resource "google_compute_firewall" "firewall_ldap_internal" {
  name          = "${var.name}-firewall-ldap-internal-rule"
  network       = google_compute_network.vpc_ldap.name
  allow {
    protocol    = "tcp"
    ports       = ["0-65535"]
  }
  allow {
    protocol    = "udp"
    ports       = ["0-65535"]
  }
  allow {
    protocol    = "icmp"
  }
  source_ranges = ["10.13.1.0/24"]
}

resource "google_compute_address" "default" {
  name          = "default-ldap-address"
  subnetwork    = google_compute_subnetwork.subnetwork_ldap.id
  address_type  = "INTERNAL"
  region        = var.region
}