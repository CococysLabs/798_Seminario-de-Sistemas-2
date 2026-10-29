variable "project_id" {
  description = "Proyecto de GCP donde se desplegaran los recursos."
  type        = string
}

variable "region" {
  description = "Region principal para el bucket."
  type        = string
  default     = "us-central1"
}

variable "bigquery_location" {
  description = "Ubicacion del dataset de BigQuery."
  type        = string
  default     = "US"
}

variable "bucket_location" {
  description = "Ubicacion del bucket de Cloud Storage."
  type        = string
  default     = "US-CENTRAL1"
}

variable "dataset_id" {
  description = "Nombre del dataset de BigQuery."
  type        = string
  default     = "semana9_novashop"
}

variable "bucket_name" {
  description = "Nombre unico global del bucket."
  type        = string
}

variable "delete_contents_on_destroy" {
  description = "Si es true, permite destruir el dataset con contenido."
  type        = bool
  default     = true
}

variable "force_destroy_bucket" {
  description = "Si es true, permite destruir el bucket aunque tenga objetos."
  type        = bool
  default     = true
}
