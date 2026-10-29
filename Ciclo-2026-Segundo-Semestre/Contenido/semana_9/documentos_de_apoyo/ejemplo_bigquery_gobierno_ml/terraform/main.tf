terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_bigquery_dataset" "semana9" {
  dataset_id                 = var.dataset_id
  location                   = var.bigquery_location
  delete_contents_on_destroy = var.delete_contents_on_destroy

  labels = {
    curso   = "seminario_sistemas_2"
    semana  = "9"
    ejemplo = "bigquery_gobierno_ml"
  }
}

resource "google_storage_bucket" "semana9_data" {
  name                        = var.bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = true
  force_destroy               = var.force_destroy_bucket

  labels = {
    curso   = "seminario_sistemas_2"
    semana  = "9"
    ejemplo = "bigquery_gobierno_ml"
  }
}

resource "local_file" "semana9_env" {
  filename = "${path.module}/.env"
  content  = <<-EOT
    GCP_PROJECT_ID=${var.project_id}
    GCP_REGION=${var.region}
    BIGQUERY_LOCATION=${var.bigquery_location}
    DATASET_ID=${google_bigquery_dataset.semana9.dataset_id}
    BUCKET_NAME=${google_storage_bucket.semana9_data.name}
    CLIENTES_URI=gs://${google_storage_bucket.semana9_data.name}/semana9/clientes.csv
    VENTAS_URI=gs://${google_storage_bucket.semana9_data.name}/semana9/ventas.csv
    SOPORTE_URI=gs://${google_storage_bucket.semana9_data.name}/semana9/soporte.csv
  EOT
}
