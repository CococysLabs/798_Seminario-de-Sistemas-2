output "dataset_id" {
  description = "Dataset creado para el ejemplo."
  value       = google_bigquery_dataset.semana9.dataset_id
}

output "bucket_name" {
  description = "Bucket creado para cargar y exportar archivos."
  value       = google_storage_bucket.semana9_data.name
}

output "clientes_uri" {
  description = "Ruta sugerida para clientes.csv."
  value       = "gs://${google_storage_bucket.semana9_data.name}/semana9/clientes.csv"
}

output "ventas_uri" {
  description = "Ruta sugerida para ventas.csv."
  value       = "gs://${google_storage_bucket.semana9_data.name}/semana9/ventas.csv"
}

output "soporte_uri" {
  description = "Ruta sugerida para soporte.csv."
  value       = "gs://${google_storage_bucket.semana9_data.name}/semana9/soporte.csv"
}
