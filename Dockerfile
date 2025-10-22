# syntax=docker/dockerfile:1.6
FROM apache/airflow:3.1.0

USER root

COPY requirements.txt /requirements.txt

# RUN set -e; \
#     PYVER="$(python - <<'PY'\nimport sys;print(f'{sys.version_info[0]}.{sys.version_info[1]}')\nPY)"; \
#     AFVER="$(python - <<'PY'\nimport airflow;print(airflow.__version__)\nPY)"; \
#     pip install --no-cache-dir --upgrade pip && \
#     pip install --no-cache-dir -r /requirements-public.txt \
#       --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AFVER}/constraints-${PYVER}.txt"


# RUN set -e; \
#     RUN set -e; \
#     PYVER="$(python - <<'PY'
#     import sys
#     v = sys.version_info
#     print(f"{v[0]}.{v[1]}")
#     PY
#     )"; \
#     AFVER="$(python - <<'PY'
#     import airflow
#     print(airflow.__version__)
#     PY
#     )"; \
#     echo "PYVER=${PYVER} AFVER=${AFVER}";


ARG NEXUS_URL=https://2c18f1f65e25.ngrok-free.app
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
    pip install --no-cache-dir -r /requirements.txt && \
    pip install --no-cache-dir --no-deps \
    --index-url "${NEXUS_URL}/repository/pypi-internal/simple" \
    "${PRIVATE_PKG}==${PRIVATE_VER}"

# USER airflow
