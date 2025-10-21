# 🚀 Sustainable Food Ordering Automation Project

This project sets up a minimum viable data automation system for a sustainable food ordering platform using Docker, Kubernetes, Airflow for ETL, PostgreSQL for data storage, and Grafana for observability.

## 📋 Project Structure

```
/project-root
├── /airflow/
│ ├── dags/
│ │ └── basic_etl_dag.py
│ └── Dockerfile
├── /db/
│ ├── init.sql
│ └── Dockerfile
├── /grafana/
│ └── provisioning/
│ └── dashboards/
│ └── pipeline_status.json
├── /k8s/
│ ├── airflow-deployment.yaml
│ ├── postgres-deployment.yaml
│ ├── grafana-deployment.yaml
│ └── namespace.yaml
├── /services/
│ └── order_service/
│ ├── main.py
│ ├── models.py
│ └── requirements.txt
├── docker-compose.yml
└── README.md
```

## 🚀 Getting Started

### 1. Local Setup with Docker Compose

1.  **Build Docker Images (if any custom images are used, like Airflow)**:
    ```bash
    docker-compose build
    ```

2.  **Spin up all services**:
    ```bash
    docker-compose up -d
    ```

3.  **Access Services**:
    *   **Airflow Webserver**: `http://localhost:8080` (User: `airflow`, Pass: `airflow` - *Note: default setup for local development*)
    *   **Grafana**: `http://localhost:3000` (User: `admin`, Pass: `admin`)
    *   **PostgreSQL**: Accessible on port `5432`.
    *   **Order Microservice**: Not managed by `docker-compose.yml` for this MVP. You'll need to run it separately.

### 2. Testing Airflow DAG

1.  Access the Airflow UI at `http://localhost:8080`.
2.  Log in with `airflow`/`airflow`.
3.  Find the `basic_etl_dag` DAG and unpause it.
4.  You can manually trigger it to run the ETL process. This DAG reads orders from PostgreSQL and writes a daily summary.

### 3. Hitting the Order Microservice Endpoints

The order microservice (FastAPI) is located in `services/order_service/`. To run it:

1.  **Install dependencies** (it's recommended to use a virtual environment):
    ```bash
    cd services/order_service
    pip install -r requirements.txt
    ```

2.  **Run the application**:
    ```bash
    uvicorn main:app --host 0.0.0.0 --port 8000 --reload
    ```

3.  **Endpoints**:
    *   **Create a new order (POST)**: `http://localhost:8000/order/`
        *   Example `curl` request:
            ```bash
            curl -X POST "http://localhost:8000/order/" \
                 -H "Content-Type: application/json" \
                 -d '{"customer_id": 1, "total": 25.00}'
            ```
    *   **Read all orders (GET)**: `http://localhost:8000/orders/`
        *   Example `curl` request:
            ```bash
            curl -X GET "http://localhost:8000/orders/"
            ```
    *   **Swagger UI**: You can also access the interactive API documentation at `http://localhost:8000/docs` once the service is running.

### 4. Deploying with Kubernetes (Minikube Example)

Assuming you have `minikube` and `kubectl` installed:

1.  **Start Minikube**:
    ```bash
    minikube start
    ```

2.  **Create Namespace**:
    ```bash
    kubectl apply -f k8s/namespace.yaml
    ```

3.  **Deploy PostgreSQL**:
    ```bash
    kubectl apply -f k8s/postgres-deployment.yaml
    ```

4.  **Deploy Airflow**:
    *   First, you need to build the Airflow Docker image so Kubernetes can use it. Navigate to the `airflow` directory and build:
        ```bash
        cd airflow
        docker build -t airflow:latest .
        minikube image load airflow:latest
        cd ..
        ```
    *   Then, deploy:
        ```bash
        kubectl apply -f k8s/airflow-deployment.yaml
        ```

5.  **Deploy Grafana**:
    ```bash
    kubectl apply -f k8s/grafana-deployment.yaml
    ```

6.  **Access Services in Minikube**:
    *   **Airflow Webserver**: 
        ```bash
        minikube service -n food-automation airflow-webserver
        ```
    *   **Grafana**: 
        ```bash
        minikube service -n food-automation grafana
        ```

## 🧹 Cleanup

### Docker Compose
```bash
docker-compose down -v
```

### Kubernetes
```bash
kubectl delete namespace food-automation
minikube stop
```
