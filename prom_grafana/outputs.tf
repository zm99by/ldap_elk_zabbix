
output "Grafana" {
  value = "http://${google_compute_instance.prometheus.network_interface.0.access_config.0.nat_ip}:3000"
}

output "Prometeus" {
  value = "http://${google_compute_instance.prometheus.network_interface.0.access_config.0.nat_ip}:9090"
}
