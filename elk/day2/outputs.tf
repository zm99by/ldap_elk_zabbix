
output "Kibana" {
  value = "http://${google_compute_instance.ek.network_interface[0].access_config[0].nat_ip}:5601"

}
output "Elasticsearch_health"{
  value = "http://${google_compute_instance.ek.network_interface[0].access_config[0].nat_ip}:9200/_cluster/health?pretty"
}

output "Elasticsearch_indexes"{
  value = "http://${google_compute_instance.ek.network_interface[0].access_config[0].nat_ip}:9200/_cat/indices?v"
}

output "Tomcat_for_deploy"{
  value = "http://${google_compute_instance.logstash_server.network_interface[0].access_config[0].nat_ip}:8080"
}
