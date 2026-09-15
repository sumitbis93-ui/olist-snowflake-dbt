# Olist Snowflake + dbt Data Model

## 1. Project Overview

This project uses the Kaggle Brazilian Olist e-commerce dataset with
**AWS S3 as the source layer** and **Snowflake as the cloud data
warehouse**. **dbt Core** provides the SQL transformation, modelling,
testing, snapshot, and incremental-processing framework.

## 2. Architecture

``` text
Kaggle Olist Dataset
        |
        v
      AWS S3
        |
        v
 Snowflake RAW Schema
        |
        v
   dbt STAGING
        |
        v
 dbt INTERMEDIATE
        |
        v
    dbt MARTS
        |
        +--> Fact Sales
        +--> Customer Dimension
        +--> Product Dimension
        +--> Seller Dimension
        +--> Sales Performance
        |
        v
    Analytics / BI

Apache Airflow
   Orchestration
```

## 3. Snowflake Object Structure

``` text
OLIST_DB
|
+-- RAW
|   +-- Raw Olist source tables
|
+-- DBT_DEV_STAGING
|   +-- Staging models
|
+-- DBT_DEV_INTERMEDIATE
|   +-- Intermediate models
|
+-- DBT_DEV_MARTS
    +-- Mart models
```

The project intentionally separates the dbt development layers into
`DBT_DEV_STAGING`, `DBT_DEV_INTERMEDIATE`, and `DBT_DEV_MARTS`.

## 4. Staging Layer

Staging models standardize and prepare raw source data for downstream
transformations.

``` text
stg_customers
stg_orders
stg_order_items
stg_order_payments
stg_order_reviews
stg_products
stg_sellers
stg_geolocation
```

Staging models are materialized as **views**.

Responsibilities include column standardization, data-type handling,
source-level cleansing, and providing stable inputs for downstream
models.

## 5. Intermediate Layer

Intermediate models contain reusable transformation and enrichment
logic:

``` text
int_order_items_enriched
int_orders_enriched
```

These models are materialized as **views** and provide a controlled
boundary between source standardization and analytical modelling.

## 6. Marts Layer

The marts layer contains analytics-ready datasets:

``` text
fct_sales
dim_customer
dim_product
dim_seller
mart_sales_performance
```

These models are materialized as **tables**.

An additional incremental model was developed:

``` text
fct_sales_incremental
```

## 7. Fact Model --- fct_sales

`fct_sales` represents sales activity at the analytical sales/order-item
grain and combines relevant information from orders, customers,
products, sellers, payments, and reviews.

The model supports analysis of:

-   Sales amount
-   Freight value
-   Order date
-   Customer
-   Product
-   Seller
-   Payment
-   Review information

## 8. Dimension Models

### dim_customer

Contains customer-level attributes including:

-   `customer_id`
-   `customer_unique_id`
-   `customer_zip_code_prefix`
-   Customer location attributes

An important modelling consideration is that `customer_unique_id` can
represent the same real customer across multiple orders. It therefore
should not automatically be treated as unique in an order-grain fact.

### dim_product

Contains product-level attributes such as:

-   `product_id`
-   Product category
-   Product descriptive attributes

### dim_seller

Contains seller-level information including:

-   `seller_id`
-   Seller location
-   Seller city/state attributes

### mart_sales_performance

Provides business-facing sales performance data for analytical
reporting.

## 9. Grain and Join Cardinality

The Olist datasets have different grains. Orders, order items, payments,
reviews, customers, sellers, products, and geolocation cannot be treated
as if they all have one-to-one relationships.

A major project finding was **join explosion**. The geolocation dataset
contains multiple records for some ZIP-code prefixes. Joining it
directly to order-level data therefore multiplied rows substantially.

The solution is to validate key uniqueness and join cardinality before
joining datasets and to aggregate or otherwise control non-unique lookup
data when required.

## 10. Surrogate Keys

The project explores surrogate-key patterns in dbt. The incremental
sales model uses:

``` text
sales_sk
```

as its `unique_key`.

The key must represent the logical grain of the target record. Customer
identifiers should not be substituted for a sales-level key merely
because they are convenient.

## 11. Data Quality in the Model

The data model is supported by:

-   Uniqueness validation
-   Not-null validation
-   Relationship validation
-   Accepted-value validation
-   Source-to-target row-count checks
-   Join-cardinality checks
-   Snapshot-based change tracking
