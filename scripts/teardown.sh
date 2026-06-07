#!/bin/bash
set -e

echo "========================================"
echo " Sustainable Food Ordering — Teardown"
echo "========================================"

echo "[1/3] Destroying Terraform resources..."
cd terraform
terraform destroy -auto-approve
cd ..
echo "✓ Terraform resources destroyed"

echo "[2/3] Deleting namespace (fallback)..."
kubectl delete namespace food-automation --ignore-not-found
echo "✓ Namespace deleted"

echo "[3/3] Stopping Minikube..."
minikube stop
echo "✓ Minikube stopped"

echo ""
echo "Teardown complete."
