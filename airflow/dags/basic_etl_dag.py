from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime

def _extract_and_load():
    postgres_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = postgres_hook.get_conn()
    cur = conn.cursor()

    # Read today's orders
    cur.execute("SELECT SUM(total) FROM orders WHERE created_at::date = CURRENT_DATE;")
    total_sales = cur.fetchone()[0]

    if total_sales is None:
        total_sales = 0.0

    # Write summary to daily_summary table
    cur.execute(
        "INSERT INTO daily_summary (date, total_sales) VALUES (CURRENT_DATE, %s) ON CONFLICT (date) DO UPDATE SET total_sales = EXCLUDED.total_sales;",
        (total_sales,)
    )
    conn.commit()
    cur.close()
    conn.close()

with DAG(
    dag_id='basic_etl_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval='@daily',
    catchup=False,
    tags=['etl', 'postgres'],
) as dag:
    extract_and_load_task = PythonOperator(
        task_id='extract_and_load',
        python_callable=_extract_and_load,
    )
