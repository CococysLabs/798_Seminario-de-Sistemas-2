variable "project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Region para recursos"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "Zona para la VM de Spark Connect"
  type        = string
  default     = "us-central1-a"
}

variable "bucket_name_prefix" {
  description = "Prefijo del bucket (debe ser lowercase)"
  type        = string
  default     = "ht3-carnet"
}

variable "vm_machine_type" {
  description = "Tipo de maquina para la VM de Spark Connect"
  type        = string
  default     = "e2-standard-4"
}

