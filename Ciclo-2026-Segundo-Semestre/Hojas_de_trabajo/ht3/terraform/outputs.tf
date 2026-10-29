output "bucket_name" {
  description = "Nombre final del bucket creado"
  value       = google_storage_bucket.carnet_bucket.name
}

output "spark_connect_vm_external_ip" {
  description = "IP publica de la VM con Spark Connect"
  value       = google_compute_instance.spark_connect_vm.network_interface[0].access_config[0].nat_ip
}

output "spark_connect_url" {
  description = "URL de Spark Connect para el cliente Python"
  value       = "sc://${google_compute_instance.spark_connect_vm.network_interface[0].access_config[0].nat_ip}:15002"
}

