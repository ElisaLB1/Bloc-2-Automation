FROM python:3.11-slim

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    netcat-traditional \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Create the airflow user and group
RUN groupadd --gid 50000 airflow \
    && useradd --uid 50000 --gid airflow --shell /bin/bash --create-home airflow

USER airflow
ENV AIRFLOW_HOME=/opt/airflow
ENV PATH="/home/airflow/.local/bin:$PATH"
WORKDIR /opt/airflow

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

USER root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
USER airflow
