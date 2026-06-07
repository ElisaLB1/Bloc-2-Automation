variable "namespace" {
  description = "Kubernetes namespace for the project"
  type        = string
  default     = "food-automation"
}

variable "postgres_db" {
  description = "PostgreSQL database name"
  type        = string
  default     = "food_ordering"
}

variable "postgres_user" {
  description = "PostgreSQL username"
  type        = string
  default     = "airflow"
}

variable "postgres_password" {
  description = "PostgreSQL password"
  type        = string
  default     = "airflow"
  sensitive   = true
}

variable "grafana_admin_password" {
  description = "Grafana admin password"
  type        = string
  default     = "admin"
  sensitive   = true
}
