terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.23"
    }
  }
  required_version = ">= 1.0"
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "minikube"
}

resource "kubernetes_namespace" "food_automation" {
  metadata {
    name = "food-automation"
    labels = {
      project     = "sustainable-food-ordering"
      environment = "local"
    }
  }
}

resource "kubernetes_deployment" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "postgres" }
    }
    template {
      metadata {
        labels = { app = "postgres" }
      }
      spec {
        container {
          name  = "postgres"
          image = "postgres:15"
          env { name = "POSTGRES_DB"       value = "food_ordering" }
          env { name = "POSTGRES_USER"     value = "airflow" }
          env { name = "POSTGRES_PASSWORD" value = "airflow" }
          port { container_port = 5432 }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  metadata {
    name      = "postgres"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    selector = { app = "postgres" }
    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_deployment" "airflow" {
  metadata {
    name      = "airflow"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "airflow" }
    }
    template {
      metadata {
        labels = { app = "airflow" }
      }
      spec {
        container {
          name              = "airflow"
          image             = "airflow:latest"
          image_pull_policy = "Never"
          env { name = "AIRFLOW__CORE__EXECUTOR" value = "LocalExecutor" }
          env { name = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN" value = "postgresql+psycopg2://airflow:airflow@postgres:5432/food_ordering" }
          port { container_port = 8080 }
        }
      }
    }
  }
}

resource "kubernetes_service" "airflow" {
  metadata {
    name      = "airflow-webserver"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    selector  = { app = "airflow" }
    type      = "NodePort"
    port {
      port        = 8080
      target_port = 8080
      node_port   = 30080
    }
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = { app = "grafana" }
    }
    template {
      metadata {
        labels = { app = "grafana" }
      }
      spec {
        container {
          name  = "grafana"
          image = "grafana/grafana:latest"
          env { name = "GF_SECURITY_ADMIN_PASSWORD" value = "admin" }
          port { container_port = 3000 }
        }
      }
    }
  }
}

resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.food_automation.metadata[0].name
  }
  spec {
    selector = { app = "grafana" }
    type     = "NodePort"
    port {
      port        = 3000
      target_port = 3000
      node_port   = 30300
    }
  }
}
