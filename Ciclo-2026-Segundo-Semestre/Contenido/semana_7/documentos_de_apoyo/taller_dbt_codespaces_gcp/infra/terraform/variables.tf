variable "project_id" {
  description = "Proyecto GCP administrado por el docente."
  type        = string
}

variable "region" {
  description = "Region principal para recursos regionales."
  type        = string
  default     = "us-central1"
}

variable "bigquery_location" {
  description = "Ubicacion de datasets BigQuery."
  type        = string
  default     = "US"
}

variable "dataset_prefixes" {
  description = "Prefijos de datasets para docente/grupos."
  type        = list(string)
  default     = ["grupo_demo"]
}

variable "bucket_name" {
  description = "Nombre global del bucket GCS para raw/evidencias. Debe ser unico globalmente."
  type        = string
}

variable "create_service_account_key" {
  description = "Crear llave JSON para Codespaces. Usar solo en talleres y rotar despues."
  type        = bool
  default     = true
}

variable "create_vm" {
  description = "Crear VM opcional para una futura demo administrada por el docente."
  type        = bool
  default     = false
}

variable "vm_name" {
  description = "Nombre de VM opcional."
  type        = string
  default     = "ss2-dbt-workshop-vm"
}

variable "vm_machine_type" {
  description = "Tipo de maquina para VM opcional."
  type        = string
  default     = "e2-medium"
}

variable "vm_zone" {
  description = "Zona para VM opcional."
  type        = string
  default     = "us-central1-a"
}

variable "allowed_ssh_cidrs" {
  description = "CIDRs permitidos para SSH si se activa la VM."
  type        = list(string)
  default     = []
}

