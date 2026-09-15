# dbt Workflow --- Olist Snowflake Data Engineering Project

## 1. Purpose

This project uses dbt Core to transform the Brazilian Olist e-commerce
dataset from raw Snowflake tables into analytics-ready fact, dimension,
and reporting models.

``` text
AWS S3
   |
   v
Snowflake RAW
   |
   v
dbt STAGING
   |
   v
dbt INTERMEDIATE
   |
   v
dbt MARTS
```

Apache Airflow is used as the orchestration pattern for scheduling and
coordinating ingestion and transformation activities.

## 2. Local Development Environment

The project was developed using:

-   Windows PowerShell
-   VS Code
-   Conda
-   Python 3.11+
-   dbt Core
-   Snowflake dbt adapter

The dedicated Conda environment is:

``` text
olist_dbt
```

The working environment used Python **3.11.16**.

Project versions:

``` text
dbt Core       : 1.12.3
dbt-snowflake  : 1.12.0
```

Using Python 3.11+ was an important setup decision after compatibility
issues were encountered with a newer system Python version.

## 3. Snowflake Configuration

Primary objects:

``` text
Database  : OLIST_DB
Warehouse : OLIST_WH
Role      : TRANSFORM
Raw Schema: RAW
```

dbt development schemas:

``` text
OLIST_DB.DBT_DEV_STAGING
OLIST_DB.DBT_DEV_INTERMEDIATE
OLIST_DB.DBT_DEV_MARTS
```

The transformation role requires appropriate permissions to create and
modify objects in these schemas.

## 4. Source and Raw Load

The Kaggle Olist datasets are stored in AWS S3 and loaded into Snowflake
`RAW`.

Conceptually:

``` text
AWS S3
  |
  v
Snowflake Stage / COPY INTO
  |
  v
OLIST_DB.RAW
```

Source loading is validated before dbt transformations are executed.
Record counts are useful for identifying an incomplete or unexpected raw
load.

## 5. dbt Project Structure

``` text
olist_dbt/
|
+-- dbt_project.yml
+-- packages.yml
|
+-- models/
|   +-- staging/
|   +-- intermediate/
|   +-- marts/
|
+-- snapshots/
+-- seeds/
+-- analyses/
+-- macros/
```

The developed project included models, snapshots, analyses, tests, a
seed, and source definitions.

## 6. Staging Workflow

Staging models reference raw sources using dbt source definitions:

``` sql
{{ source('source_name', 'table_name') }}
```

They standardize source structures before downstream transformations.

## 7. Intermediate Workflow

Intermediate models use `ref()` to establish dependencies:

``` sql
{{ ref('stg_orders') }}
```

Example:

``` text
stg_orders
     |
     v
int_orders_enriched

stg_order_items
     |
     v
int_order_items_enriched
```

dbt uses these dependencies to build the model DAG and determine
execution order.

## 8. Mart Workflow

The mart layer consumes staging and intermediate models:

``` text
STAGING
   |
   v
INTERMEDIATE
   |
   v
MARTS
```

Core models:

``` text
fct_sales
dim_customer
dim_product
dim_seller
mart_sales_performance
```

## 9. Materializations

  Layer          Materialization   Purpose
  -------------- ----------------- ----------------------------------------
  Staging        View              Lightweight source standardization
  Intermediate   View              Reusable transformation and enrichment
  Marts          Table             Persisted analytical datasets
  Incremental    Incremental       New/changed record processing

## 10. Core dbt Commands

Connection/configuration validation:

``` powershell
dbt debug
```

Install packages:

``` powershell
dbt deps
```

Run models:

``` powershell
dbt run
```

Run tests:

``` powershell
dbt test
```

Run snapshots:

``` powershell
dbt snapshot
```

Run the project build:

``` powershell
dbt build
```

## 11. dbt Dependency Management

The project used `packages.yml` for dbt package management and explored
`dbt_utils`.

During setup, package semantic-version and compatibility errors were
encountered. This reinforced the need to verify package versions against
the installed dbt environment before executing `dbt deps`.

## 12. Airflow Orchestration Pattern

Apache Airflow provides the orchestration pattern:

``` text
Start
  |
  v
Validate / Ingest Source
  |
  v
Load Snowflake RAW
  |
  v
Run dbt Transformations
  |
  v
Run dbt Tests
  |
  v
Run Snapshots / Incremental Models
  |
  v
Publish Analytics Models
```

Airflow is therefore positioned as the scheduler and
dependency-management layer around the ingestion and dbt workflow.

## 13. End-to-End Workflow

1.  Source data is available in AWS S3.
2.  Data is loaded into Snowflake `RAW`.
3.  Raw record counts and load status are validated.
4.  dbt staging views standardize source data.
5.  Intermediate views apply enrichment and reusable business logic.
6.  Mart tables create analytical fact and dimension datasets.
7.  dbt tests validate data quality.
8.  Snapshots capture selected historical changes.
9.  Incremental models process new/changed sales records.
10. Analytics/BI tools consume the mart layer.
