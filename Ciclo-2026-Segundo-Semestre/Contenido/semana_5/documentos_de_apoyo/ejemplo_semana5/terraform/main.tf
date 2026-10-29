terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 6.0.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc" {
  name                    = "${var.name_prefix}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = "${var.name_prefix}-subnet"
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "allow_sqlserver" {
  name    = "${var.name_prefix}-allow-sqlserver"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["1433"]
  }

  source_ranges = var.allowed_cidrs_sql
  target_tags   = ["sqlserver"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.name_prefix}-allow-ssh"
  network = google_compute_network.vpc.name

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = var.allowed_cidrs_ssh
  target_tags   = ["sqlserver", "ssh"]
}

resource "google_compute_disk" "sql_data_disk" {
  name = "${var.name_prefix}-sqldata"
  type = var.data_disk_type
  zone = var.zone
  size = var.data_disk_size_gb
}

resource "google_compute_instance" "sqlserver_vm" {
  name         = "${var.name_prefix}-vm"
  machine_type = var.machine_type
  zone         = var.zone
  tags         = ["sqlserver", "ssh"]

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2204-lts"
      size  = var.boot_disk_size_gb
      type  = var.boot_disk_type
    }
  }

  attached_disk {
    source      = google_compute_disk.sql_data_disk.id
    device_name = "sqldata"
  }

  network_interface {
    subnetwork   = google_compute_subnetwork.subnet.id
    access_config {}
  }

  metadata = {
    enable-oslogin = "FALSE"
    startup-script = templatefile("${path.module}/startup.tpl.sh", {
      sa_password = var.sa_password
      datamart_db = var.datamart_db
    })
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}
