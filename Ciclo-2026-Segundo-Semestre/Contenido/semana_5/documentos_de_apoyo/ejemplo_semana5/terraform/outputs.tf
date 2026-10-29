output "sqlserver_public_ip" {
  description = "IP publica de la VM con SQL Server"
  value       = google_compute_instance.sqlserver_vm.network_interface[0].access_config[0].nat_ip
}

output "sqlserver_connection_example" {
  description = "Ejemplo de host para conexiones ODBC"
  value       = "${google_compute_instance.sqlserver_vm.network_interface[0].access_config[0].nat_ip},1433"
}
