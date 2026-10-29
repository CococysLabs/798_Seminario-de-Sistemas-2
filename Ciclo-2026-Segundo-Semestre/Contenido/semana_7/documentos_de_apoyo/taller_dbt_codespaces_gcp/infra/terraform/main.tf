provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  dataset_suffixes = toset(["raw", "staging", "intermediate", "marts"])

  datasets = {
    for item in setproduct(toset(var.dataset_prefixes), local.dataset_suffixes) :
    "${item[0]}_${item[1]}" => {
      prefix = item[0]
      suffix = item[1]
    }
  }
}

resource "google_bigquery_dataset" "workshop" {
  for_each = local.datasets

  dataset_id                 = each.key
  friendly_name              = "SS2 dbt workshop ${each.key}"
  description                = "Dataset ${each.value.suffix} para el taller dbt de Seminario de Sistemas 2."
  location                   = var.bigquery_location
  delete_contents_on_destroy = true

  labels = {
    course = "ss2"
    tool   = "dbt"
    layer  = each.value.suffix
  }
}

resource "google_storage_bucket" "raw" {
  name                        = var.bucket_name
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = {
    course = "ss2"
    tool   = "dbt"
  }
}

resource "google_service_account" "codespaces" {
  account_id   = "ss2-dbt-codespaces"
  display_name = "SS2 dbt Codespaces Workshop"
  description  = "Service account usada por GitHub Codespaces para ejecutar dbt en BigQuery."
}

resource "google_project_iam_member" "bigquery_job_user" {
  project = var.project_id
  role    = "roles/bigquery.jobUser"
  member  = google_service_account.codespaces.member
}

resource "google_bigquery_dataset_iam_member" "dataset_editor" {
  for_each = google_bigquery_dataset.workshop

  project    = var.project_id
  dataset_id = each.value.dataset_id
  role       = "roles/bigquery.dataEditor"
  member     = google_service_account.codespaces.member
}

resource "google_storage_bucket_iam_member" "bucket_object_admin" {
  bucket = google_storage_bucket.raw.name
  role   = "roles/storage.objectAdmin"
  member = google_service_account.codespaces.member
}

resource "google_service_account_key" "codespaces" {
  count              = var.create_service_account_key ? 1 : 0
  service_account_id = google_service_account.codespaces.name
}

resource "google_compute_network" "vm_network" {
  count                   = var.create_vm ? 1 : 0
  name                    = "ss2-dbt-workshop-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "vm_subnet" {
  count         = var.create_vm ? 1 : 0
  name          = "ss2-dbt-workshop-subnet"
  ip_cidr_range = "10.70.0.0/24"
  region        = var.region
  network       = google_compute_network.vm_network[0].id
}

resource "google_compute_firewall" "ssh" {
  count   = var.create_vm && length(var.allowed_ssh_cidrs) > 0 ? 1 : 0
  name    = "ss2-dbt-workshop-allow-ssh"
  network = google_compute_network.vm_network[0].name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_ssh_cidrs
  target_tags   = ["ss2-dbt-workshop"]
}

resource "google_compute_instance" "workshop" {
  count        = var.create_vm ? 1 : 0
  name         = var.vm_name
  machine_type = var.vm_machine_type
  zone         = var.vm_zone
  tags         = ["ss2-dbt-workshop"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = 30
      type  = "pd-balanced"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.vm_subnet[0].id
    access_config {}
  }

  metadata = {
    enable-oslogin = "TRUE"
    startup-script = file("${path.module}/startup.tpl.sh")
  }

  service_account {
    email  = google_service_account.codespaces.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

