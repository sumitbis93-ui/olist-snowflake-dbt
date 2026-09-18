from datetime import datetime, timedelta
from pathlib import Path

from airflow.decorators import dag
from airflow.providers.common.sql.operators.sql import SQLExecuteQueryOperator

from cosmos import (
    DbtTaskGroup,
    ProjectConfig,
    ProfileConfig,
    ExecutionConfig,
)

from cosmos.profiles import SnowflakeUserPasswordProfileMapping


# -------------------------------------------------------------------
# PATHS
# -------------------------------------------------------------------

DBT_PROJECT_PATH = (
    Path("/usr/local/airflow")
    / "dbt"
    / "olist_dbt"
)


DBT_EXECUTABLE = (
    "/usr/local/airflow/dbt_venv/bin/dbt"
)


# -------------------------------------------------------------------
# DBT PROFILE
# -------------------------------------------------------------------

profile_config = ProfileConfig(
    profile_name="olist_dbt",
    target_name="dev",

    profile_mapping=SnowflakeUserPasswordProfileMapping(
        conn_id="snowflake_olist",

        profile_args={
            "database": "OLIST_DB",
            "schema": "DBT_DEV_STAGING",
            "warehouse": "OLIST_WH",
            "role": "TRANSFORM",
            "threads": 4,
        },
    ),
)


# -------------------------------------------------------------------
# DBT EXECUTION
# -------------------------------------------------------------------

execution_config = ExecutionConfig(
    dbt_executable_path=DBT_EXECUTABLE
)


# -------------------------------------------------------------------
# DAG
# -------------------------------------------------------------------

@dag(
    dag_id="olist_master_pipeline",

    start_date=datetime(2026, 9, 1),

    schedule="0 2 * * *",

    catchup=False,

    max_active_runs=1,

    default_args={
        "owner": "sumit",
        "retries": 2,
        "retry_delay": timedelta(minutes=5),
    },

    tags=[
        "olist",
        "snowflake",
        "dbt",
        "data-engineering",
    ],

    description=(
        "End-to-end Olist Snowflake and dbt "
        "ELT pipeline orchestrated by Airflow"
    ),
)
def olist_master_pipeline():

    # ---------------------------------------------------------------
    # 1. START / SNOWFLAKE VALIDATION
    # ---------------------------------------------------------------

    validate_snowflake = SQLExecuteQueryOperator(
        task_id="validate_snowflake_connection",

        conn_id="snowflake_olist",

        sql="""
        SELECT
            CURRENT_USER() AS CURRENT_USER,
            CURRENT_ROLE() AS CURRENT_ROLE,
            CURRENT_DATABASE() AS CURRENT_DATABASE,
            CURRENT_SCHEMA() AS CURRENT_SCHEMA,
            CURRENT_WAREHOUSE() AS CURRENT_WAREHOUSE;
        """,

        hook_params={
            "warehouse": "OLIST_WH",
        },
    )


    # ---------------------------------------------------------------
    # 2. VALIDATE RAW DATA
    # ---------------------------------------------------------------

    validate_raw_data = SQLExecuteQueryOperator(
        task_id="validate_raw_data",

        conn_id="snowflake_olist",

        sql="""
        SELECT
            COUNT(*) AS RAW_ORDER_COUNT
        FROM OLIST_DB.RAW.RAW_ORDERS
        HAVING COUNT(*) > 0;
        """,

        hook_params={
            "warehouse": "OLIST_WH",
        },
    )


    # ---------------------------------------------------------------
    # 3. DBT
    # ---------------------------------------------------------------

    dbt_build = DbtTaskGroup(

        group_id="dbt_build",

        project_config=ProjectConfig(
            dbt_project_path=DBT_PROJECT_PATH,
        ),

        profile_config=profile_config,

        execution_config=execution_config,

        operator_args={
            "install_deps": True,
        },
    )


    # ---------------------------------------------------------------
    # 4. MART VALIDATION
    # ---------------------------------------------------------------

    validate_marts = SQLExecuteQueryOperator(
        task_id="validate_marts",

        conn_id="snowflake_olist",

        sql="""
        SELECT
            COUNT(*) AS MART_ROW_COUNT
        FROM OLIST_DB.DBT_DEV_MARTS.FCT_SALES
        HAVING COUNT(*) > 0;
        """,

        hook_params={
            "warehouse": "OLIST_WH",
        },
    )


    # ---------------------------------------------------------------
    # DEPENDENCIES
    # ---------------------------------------------------------------

    (
        validate_snowflake
        >> validate_raw_data
        >> dbt_build
        >> validate_marts
    )


olist_master_pipeline()
