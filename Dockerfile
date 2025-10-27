# syntax=docker/dockerfile:1.6
FROM apache/airflow:3.1.0

USER root

COPY requirements.txt /requirements.txt


# ARG NEXUS_URL=https://c3054db9fb32.ngrok-free.app/repository/pypi-internal/simple
ARG INDEX_URL=https://pypi.org/simple
ENV PYPI_URL=${INDEX_URL}
# ARG NEXUS_PORT=8081
ARG PRIVATE_PKG=sleep_disorder
ARG PRIVATE_VER=0.1.0
    

RUN --mount=type=secret,id=nexus_user \
    --mount=type=secret,id=nexus_pass \
    set -e; \
    U="$(cat /run/secrets/nexus_user)"; \
    P="$(cat /run/secrets/nexus_pass)";

USER airflow

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r /requirements.txt
    
RUN pip install --no-cache-dir --no-deps \
    --index-url "${PYPI_URL}" \
    /custom_requirements.txt
