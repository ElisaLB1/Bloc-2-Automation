#!/bin/bash

# Wait for PostgreSQL to be ready
for i in $(seq 1 30); do
  if nc -z "${AIRFLOW_DATABASE_HOST}" "${AIRFLOW_DATABASE_PORT}"; then
    break
  fi
  echo "Waiting for DB"
  sleep 1
done

# Initialize the database and create admin user
airflow db init
airflow users create -u admin -f admin -l admin -r Admin -e admin@example.com -p admin || true

exec "$@"
