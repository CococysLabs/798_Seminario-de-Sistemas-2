output "project_id" {
  value = var.project_id
}

output "bigquery_location" {
  value = var.bigquery_location
}

output "dataset_ids" {
  value = sort(keys(google_bigquery_dataset.workshop))
}

output "bucket_name" {
  value = google_storage_bucket.raw.name
}

output "service_account_email" {
  value = google_service_account.codespaces.email
}

output "service_account_key_json" {
  description = "JSON para secreto GCP_SERVICE_ACCOUNT_KEY_JSON en Codespaces. Sensible; rotar al finalizar."
  value       = var.create_service_account_key ? base64decode(google_service_account_key.codespaces[0].private_key) : null
  sensitive   = true
}

output "vm_external_ip" {
  value = var.create_vm ? google_compute_instance.workshop[0].network_interface[0].access_config[0].nat_ip : null
}

