from airflow import DAG
from airflow.providers.postgres.hooks.postgres import PostgresHook
from airflow.operators.python import PythonOperator
from datetime import datetime, date


def _load_dim_date(target_date):
    hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = hook.get_conn()
    cur = conn.cursor()
    cur.execute("""
        INSERT INTO dim_date (date_id, day, month, quarter, year, is_weekend)
        VALUES (%s, %s, %s, %s, %s, %s)
        ON CONFLICT (date_id) DO NOTHING
    """, (
        target_date,
        target_date.day,
        target_date.month,
        (target_date.month - 1) // 3 + 1,
        target_date.year,
        target_date.weekday() >= 5
    ))
    conn.commit()
    cur.close()
    conn.close()


def _load_dimensions():
    hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = hook.get_conn()
    cur = conn.cursor()

    cur.execute("""
        INSERT INTO dim_customer (customer_id, full_name, email, city, region, created_at)
        SELECT customer_id,
               first_name || ' ' || last_name,
               email, city, region, created_at
        FROM customers
        ON CONFLICT (customer_id) DO UPDATE
            SET full_name = EXCLUDED.full_name,
                city      = EXCLUDED.city,
                region    = EXCLUDED.region
    """)

    cur.execute("""
        INSERT INTO dim_supplier (supplier_id, name, certification)
        SELECT supplier_id, name, certification
        FROM suppliers
        ON CONFLICT (supplier_id) DO UPDATE
            SET name          = EXCLUDED.name,
                certification = EXCLUDED.certification
    """)

    cur.execute("""
        INSERT INTO dim_product (product_id, name, category, supplier_name, is_sustainable)
        SELECT p.product_id, p.name, p.category, s.name, p.is_sustainable
        FROM products p
        JOIN suppliers s ON p.supplier_id = s.supplier_id
        ON CONFLICT (product_id) DO UPDATE
            SET name           = EXCLUDED.name,
                category       = EXCLUDED.category,
                supplier_name  = EXCLUDED.supplier_name,
                is_sustainable = EXCLUDED.is_sustainable
    """)

    conn.commit()
    cur.close()
    conn.close()


def _load_facts(**context):
    target_date = date.fromisoformat(context["ds"])
    hook = PostgresHook(postgres_conn_id="postgres_default")
    conn = hook.get_conn()
    cur = conn.cursor()

    _load_dim_date(target_date)

    cur.execute("""
        INSERT INTO fact_order_items
            (order_item_id, order_id, customer_id, product_id, supplier_id,
             date_id, quantity, unit_price, total)
        SELECT
            oi.item_id,
            oi.order_id,
            o.customer_id,
            oi.product_id,
            p.supplier_id,
            o.order_date::date,
            oi.quantity,
            oi.unit_price,
            oi.quantity * oi.unit_price
        FROM order_items oi
        JOIN orders   o ON oi.order_id   = o.order_id
        JOIN products p ON oi.product_id = p.product_id
        WHERE o.order_date::date = %s
        ON CONFLICT (order_item_id) DO UPDATE
            SET quantity   = EXCLUDED.quantity,
                unit_price = EXCLUDED.unit_price,
                total      = EXCLUDED.total
    """, (target_date,))

    conn.commit()
    cur.close()
    conn.close()


with DAG(
    dag_id="basic_etl_dag",
    start_date=datetime(2024, 1, 1),
    schedule_interval="@daily",
    catchup=False,
    tags=["etl", "postgres", "star-schema"],
) as dag:

    load_dims = PythonOperator(
        task_id="load_dimensions",
        python_callable=_load_dimensions,
    )

    load_facts = PythonOperator(
        task_id="load_fact_order_items",
        python_callable=_load_facts,
    )

    load_dims >> load_facts
