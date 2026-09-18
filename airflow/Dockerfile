FROM astrocrpublic.azurecr.io/runtime:3.3-6

USER root

# Create an isolated Python environment for dbt
RUN python -m venv /usr/local/airflow/dbt_venv

# Install dbt and the Snowflake adapter
RUN /usr/local/airflow/dbt_venv/bin/pip install --no-cache-dir \
    dbt-core==1.12.3 \
    dbt-snowflake==1.12.0

USER astro
