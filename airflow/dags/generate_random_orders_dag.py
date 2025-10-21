from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime
import random

def _generate_random_order():
    postgres_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = postgres_hook.get_conn()
    cur = conn.cursor()

    # Get existing customer IDs
    cur.execute("SELECT id FROM customers;")
    customer_ids = [row[0] for row in cur.fetchall()]

    if not customer_ids:
        print("No customers found in the database. Cannot generate orders.")
        cur.close()
        conn.close()
        return

    # Generate random order data
    random_customer_id = random.choice(customer_ids)
    random_total = round(random.uniform(5.00, 100.00), 2)

    # Insert new order
    cur.execute(
        "INSERT INTO orders (customer_id, total, created_at) VALUES (%s, %s, CURRENT_TIMESTAMP);",
        (random_customer_id, random_total)
    )
    conn.commit()
    print(f"Generated new order for customer_id {random_customer_id} with total {random_total}.")

    cur.close()
    conn.close()

with DAG(
    dag_id='generate_random_orders_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Run manually
    catchup=False,
    tags=['data_generation', 'postgres'],
) as dag:
    generate_order_task = PythonOperator(
        task_id='generate_random_order',
        python_callable=_generate_random_order,
    )
