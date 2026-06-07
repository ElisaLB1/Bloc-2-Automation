output "namespace" {
  description = "Kubernetes namespace created"
  value       = kubernetes_namespace.food_automation.metadata[0].name
}

output "airflow_url" {
  description = "Airflow webserver URL (via minikube service)"
  value       = "Run: minikube service -n food-automation airflow-webserver"
}

output "grafana_url" {
  description = "Grafana URL (via minikube service)"
  value       = "Run: minikube service -n food-automation grafana"
}

output "postgres_host" {
  description = "PostgreSQL service host inside the cluster"
  value       = "postgres.food-automation.svc.cluster.local:5432"
}
