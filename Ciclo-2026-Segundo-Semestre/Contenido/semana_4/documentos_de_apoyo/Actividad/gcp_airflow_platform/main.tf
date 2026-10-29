provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "apis" {
  for_each           = toset(["compute.googleapis.com", "iamcredentials.googleapis.com", "sts.googleapis.com"])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "random_password" "admin" {
  length  = 20
  special = false
}

resource "random_password" "viewer" {
  length  = 20
  special = false
}

resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "api_secret" {
  length  = 64
  special = false
}

resource "random_id" "fernet" {
  byte_length = 32
}

resource "google_storage_bucket" "dags" {
  name                        = "${var.project_id}-airflow-dags"
  location                    = var.region
  uniform_bucket_level_access = true
  force_destroy               = false
  versioning { enabled = true }
}

resource "google_service_account" "airflow" {
  account_id   = "ss2-airflow-runtime"
  display_name = "SS2 Airflow runtime"
}

resource "google_service_account" "github" {
  account_id   = "ss2-airflow-github"
  display_name = "SS2 Airflow GitHub deploy"
}

resource "google_storage_bucket_iam_member" "runtime_reader" {
  bucket = google_storage_bucket.dags.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.airflow.email}"
}

resource "google_storage_bucket_iam_member" "runtime_bucket_reader" {
  bucket = google_storage_bucket.dags.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.airflow.email}"
}

resource "google_storage_bucket_iam_member" "github_writer" {
  bucket = google_storage_bucket.dags.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.github.email}"
}

resource "google_storage_bucket_iam_member" "github_bucket_reader" {
  bucket = google_storage_bucket.dags.name
  role   = "roles/storage.legacyBucketReader"
  member = "serviceAccount:${google_service_account.github.email}"
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "ss2-airflow-github"
  display_name              = "SS2 Airflow GitHub"
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github"
  display_name                       = "GitHub Actions"
  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository == '${var.github_repository}'"
  oidc { issuer_uri = "https://token.actions.githubusercontent.com" }
}

resource "google_service_account_iam_member" "github_wif" {
  service_account_id = google_service_account.github.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repository}"
}

resource "google_compute_firewall" "airflow_ui" {
  name    = "ss2-airflow-ui"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ss2-airflow"]
}

resource "google_compute_instance" "airflow" {
  name         = "ss2-airflow"
  zone         = var.zone
  machine_type = "n2-standard-2"
  tags         = ["ss2-airflow"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 30
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
  service_account {
    email  = google_service_account.airflow.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = templatefile("${path.module}/startup.sh.tftpl", {
    bucket          = google_storage_bucket.dags.name
    admin_password  = random_password.admin.result
    viewer_password = random_password.viewer.result
    jwt_secret      = random_password.jwt_secret.result
    api_secret      = random_password.api_secret.result
    fernet_key      = "${random_id.fernet.b64_url}="
  })
  depends_on = [google_project_service.apis, google_storage_bucket_iam_member.runtime_reader]
}

output "airflow_url" {
  value = "http://${google_compute_instance.airflow.network_interface[0].access_config[0].nat_ip}:8080"
}
output "dag_bucket" {
  value = google_storage_bucket.dags.name
}
output "github_service_account" {
  value = google_service_account.github.email
}
output "workload_identity_provider" {
  value = google_iam_workload_identity_pool_provider.github.name
}
output "admin_password" {
  value     = random_password.admin.result
  sensitive = true
}
output "viewer_password" {
  value     = random_password.viewer.result
  sensitive = true
}
