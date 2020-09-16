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

resource "google_compute_instance" "vm1" {
  name                    = "${var.name}-vm1"
  machine_type            = var.vm1_machine_type
  tags                    = var.vm1_tags
 
  boot_disk {
    initialize_params {
      image               = var.vm1_image
    }
  }

  network_interface {
    network               = google_compute_network.vpc_ldap.name
    subnetwork            = google_compute_subnetwork.subnetwork_ldap.name

    access_config {
      
    }
  }
  
  metadata_startup_script = templatefile("install.sh",{ API_KEY = "${var.api_key}" })
}

resource "google_compute_firewall" "firewall_ldap_server" {
  name                    = "${var.name}-firewall-ldap-server"
  network                 = google_compute_network.vpc_ldap.name
  source_ranges           = var.firewall_ldap_server_source_ranges

  allow {
    protocol              = var.firewall_ldap_server_protocol
    ports                 = var.firewall_ldap_server_ports
  }

  source_tags             = var.vm1_tags
}

provider "datadog" {
  api_key = var.api_key
  app_key = var.app_key
  api_url = var.api_url
  
}

resource "datadog_monitor" "monitor" {
  name               = "test"
  type               = "metric alert"
  message            = "Monitor triggered. Notify: zedex@tut.by"
  query              = "sum(last_5m):avg:datadog.agent.started{http-server} by {host}.as_count() < 1"
  depends_on         = [google_compute_instance.vm1]
}