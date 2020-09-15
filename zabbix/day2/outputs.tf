
output "Zabbix_server" {
  value = "http://${google_compute_instance.server.network_interface[0].access_config[0].nat_ip}:80/zabbix"

}

output "Tomcat_for_deploy"{
  value = "http://${google_compute_instance.client.network_interface[0].access_config[0].nat_ip}:8080"
}