terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

data "google_compute_default_service_account" "default" {
  project = var.project_id
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

locals {
  bucket_name = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
}

resource "google_storage_bucket" "carnet_bucket" {
  name                        = local.bucket_name
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  labels = {
    app   = "ht3"
    owner = "spark-connect"
  }
}

resource "google_storage_bucket_iam_member" "vm_object_admin" {
  bucket = google_storage_bucket.carnet_bucket.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${data.google_compute_default_service_account.default.email}"
}

resource "google_compute_firewall" "spark_connect_ingress" {
  name    = "ht3-spark-connect-ingress"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "15002", "7077", "8080", "8081"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ht3-spark-connect"]
}

resource "google_compute_instance" "spark_connect_vm" {
  name         = "ht3-spark-connect-vm"
  machine_type = var.vm_machine_type
  zone         = var.zone
  tags         = ["ht3-spark-connect"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 30
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    apt-get update
    apt-get install -y docker.io docker-compose
    systemctl enable docker
    systemctl start docker

    mkdir -p /opt/spark
    cat > /opt/spark/docker-compose.yml <<'EOF'
    services:
      spark-master:
        image: apache/spark:4.0.0
        container_name: spark-master
        command:
          - /opt/spark/bin/spark-class
          - org.apache.spark.deploy.master.Master
          - --host
          - spark-master
          - --port
          - "7077"
          - --webui-port
          - "8080"
        ports:
          - "7077:7077"
          - "8080:8080"
        networks: [spark-net]

      spark-worker-1:
        image: apache/spark:4.0.0
        container_name: spark-worker-1
        command:
          - /opt/spark/bin/spark-class
          - org.apache.spark.deploy.worker.Worker
          - spark://spark-master:7077
          - --webui-port
          - "8081"
          - --memory
          - 12G
          - --cores
          - "6"
        ports:
          - "8081:8081"
        networks: [spark-net]
        depends_on: [spark-master]

      spark-connect:
        image: apache/spark:4.0.0
        container_name: spark-connect
        environment:
          - HOME=/tmp
        command:
          - /bin/bash
          - -lc
          - >
            /opt/spark/sbin/start-connect-server.sh
            --master spark://spark-master:7077
            --packages com.google.cloud.bigdataoss:gcs-connector:hadoop3-2.2.28
            --conf spark.jars.ivy=/tmp/.ivy
            --conf spark.driver.extraJavaOptions=-Duser.home=/tmp
            --conf spark.hadoop.fs.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFileSystem
            --conf spark.hadoop.fs.AbstractFileSystem.gs.impl=com.google.cloud.hadoop.fs.gcs.GoogleHadoopFS
            --conf spark.connect.grpc.binding.address=0.0.0.0
            --conf spark.connect.grpc.binding.port=15002 &&
            tail -f /opt/spark/logs/*connect*.out
        ports:
          - "15002:15002"
        networks: [spark-net]
        depends_on: [spark-master, spark-worker-1]

    networks:
      spark-net:
        driver: bridge
    EOF

    cd /opt/spark
    docker-compose up -d
  EOT
}

