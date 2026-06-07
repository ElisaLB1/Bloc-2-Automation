#!/bin/bash
set -e

echo "========================================"
echo " Sustainable Food Ordering — Deploy"
echo "========================================"

echo "[1/4] Starting Minikube..."
minikube start
echo "✓ Minikube started"

echo "[2/4] Building Airflow Docker image..."
cd airflow
docker build -t airflow:latest .
minikube image load airflow:latest
cd ..
echo "✓ Airflow image built and loaded"

echo "[3/4] Running Terraform..."
cd terraform
terraform init
terraform apply -auto-approve
cd ..
echo "✓ Infrastructure deployed"

echo "[4/4] Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n food-automation --timeout=120s
kubectl wait --for=condition=ready pod -l app=airflow  -n food-automation --timeout=120s
kubectl wait --for=condition=ready pod -l app=grafana  -n food-automation --timeout=120s
echo "✓ All pods ready"

echo ""
echo "Access:"
echo "  Airflow  → minikube service -n food-automation airflow-webserver"
echo "  Grafana  → minikube service -n food-automation grafana"
echo "  Airflow credentials  → airflow / airflow"
echo "  Grafana credentials  → admin / admin"
