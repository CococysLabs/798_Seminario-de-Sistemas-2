variable "project_id" {
  type = string
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "zone" {
  type    = string
  default = "us-central1-a"
}

variable "name_prefix" {
  type    = string
  default = "sgfood"
}

variable "subnet_cidr" {
  type    = string
  default = "10.10.0.0/24"
}

# Para clase: limita a IPs del laboratorio/campus o VPN.
variable "allowed_cidrs" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "allowed_cidrs_rdp" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

# Capacidad sugerida para ~60 conexiones: 4 vCPU / 16 GB suele ser suficiente en laboratorio
variable "machine_type" {
  type    = string
  default = "e2-standard-4"
}

variable "boot_disk_size_gb" {
  type    = number
  default = 80
}

variable "boot_disk_type" {
  type    = string
  default = "pd-balanced"
}

variable "data_disk_size_gb" {
  type    = number
  default = 200
}

variable "data_disk_type" {
  type    = string
  default = "pd-ssd"
}
