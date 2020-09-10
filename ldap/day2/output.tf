output "LDAP" {
  value = "http://${google_compute_instance.vm-server.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

output "SSH" {
  value = "ssh dsakhonchik@${google_compute_instance.vm-client.network_interface.0.access_config.0.nat_ip}"
}