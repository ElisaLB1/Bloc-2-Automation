#!/bin/bash

echo "========================================"
echo " Sustainable Food Ordering — Health Check"
echo "========================================"

NAMESPACE="food-automation"

echo ""
echo "── Pods ─────────────────────────────────"
kubectl get pods -n $NAMESPACE

echo ""
echo "── Services ─────────────────────────────"
kubectl get services -n $NAMESPACE

echo ""
echo "── Pod status ───────────────────────────"
for app in postgres airflow grafana; do
  STATUS=$(kubectl get pods -n $NAMESPACE -l app=$app -o jsonpath='{.items[0].status.phase}' 2>/dev/null || echo "NOT FOUND")
  echo "  $app → $STATUS"
done

echo ""
echo "Health check complete."
