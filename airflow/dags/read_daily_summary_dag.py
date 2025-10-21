from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime

def _read_daily_summary():
    postgres_hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = postgres_hook.get_conn()
    cur = conn.cursor()

    cur.execute("SELECT date, total_sales FROM daily_summary ORDER BY date DESC;")
    summary_data = cur.fetchall()

    if summary_data:
        print("\n--- Daily Summary Data ---")
        for row in summary_data:
            print(f"Date: {row[0]}, Total Sales: {row[1]}")
        print("--------------------------")
    else:
        print("No data found in daily_summary table.")

    cur.close()
    conn.close()

with DAG(
    dag_id='read_daily_summary_dag',
    start_date=datetime(2023, 1, 1),
    schedule_interval=None,  # Run manually
    catchup=False,
    tags=['reporting', 'postgres'],
) as dag:
    read_summary_task = PythonOperator(
        task_id='read_daily_summary',
        python_callable=_read_daily_summary,
    )
