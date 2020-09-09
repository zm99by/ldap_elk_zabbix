output "LDAP" {
  value = "http://${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}/ldapadmin/"
}

#output "SSH" {
#  value = "ssh ${var.ssh_user}@${google_compute_instance.vm1.network_interface.0.access_config.0.nat_ip}"
#}