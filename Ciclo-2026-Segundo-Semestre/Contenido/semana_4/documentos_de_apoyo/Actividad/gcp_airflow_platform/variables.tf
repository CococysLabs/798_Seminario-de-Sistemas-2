variable "project_id" {
  type = string
}
variable "region" {
  type    = string
  default = "us-central1"
}
variable "zone" {
  type    = string
  default = "us-east1-b"
}
variable "github_repository" {
  type    = string
  default = "SS2-USAC/apache_airflow"
}
