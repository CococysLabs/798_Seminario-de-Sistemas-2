variable "project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Region de despliegue"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona de despliegue"
  type        = string
  default     = "us-central1-a"
}

variable "name_prefix" {
  description = "Prefijo para nombrar recursos"
  type        = string
  default     = "sem5-ventas"
}

variable "subnet_cidr" {
  description = "Rango CIDR de la subred"
  type        = string
  default     = "10.50.0.0/24"
}

variable "allowed_cidrs_sql" {
  description = "CIDRs permitidos al puerto 1433"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "allowed_cidrs_ssh" {
  description = "CIDRs permitidos para SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "machine_type" {
  description = "Tipo de maquina"
  type        = string
  default     = "e2-standard-2"
}

variable "boot_disk_size_gb" {
  description = "Tamano del disco de arranque"
  type        = number
  default     = 50
}

variable "boot_disk_type" {
  description = "Tipo de disco de arranque"
  type        = string
  default     = "pd-balanced"
}

variable "data_disk_size_gb" {
  description = "Tamano del disco de datos para SQL Server"
  type        = number
  default     = 100
}

variable "data_disk_type" {
  description = "Tipo de disco de datos"
  type        = string
  default     = "pd-standard"
}

variable "datamart_db" {
  description = "Nombre de la base de datos del datamart"
  type        = string
  default     = "ventas_dm"
}

variable "sa_password" {
  description = "Contrasena del usuario sa para SQL Server"
  type        = string
  sensitive   = true
}
