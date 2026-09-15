# dbt Testing Strategy --- Olist Snowflake Project

## 1. Purpose

Data quality is an integral part of the Olist Snowflake + dbt workflow.
dbt tests are used to validate model assumptions before analytical data
is consumed.

The project focuses on:

-   Uniqueness
-   Not-null requirements
-   Referential relationships
-   Accepted values
-   Model grain
-   Source-to-target consistency
-   Join cardinality

## 2. Test Types

### Uniqueness

Use uniqueness tests when a column is expected to identify one record.

``` yaml
columns:
  - name: order_id
    tests:
      - unique
```

The test must match the model grain. A value that is unique in one model
may legitimately repeat in another.

### Not Null

``` yaml
columns:
  - name: order_id
    tests:
      - not_null
```

This validates mandatory identifiers and prevents incomplete records
from silently reaching downstream models.

### Relationships

``` yaml
columns:
  - name: customer_id
    tests:
      - relationships:
          to: ref('stg_customers')
          field: customer_id
```

Relationship tests validate expected referential integrity.

### Accepted Values

``` yaml
columns:
  - name: review_score
    tests:
      - accepted_values:
          values: [1, 2, 3, 4, 5]
```

These tests are appropriate for controlled categorical values.

## 3. Model-Grain Testing

A central lesson from the project is:

> Define the grain first, then define the test.

For example:

``` text
customer_id
customer_unique_id
```

have different modelling meanings.

`customer_unique_id` may occur across multiple orders and therefore
should not automatically receive a uniqueness test in an order-grain
model.

## 4. Relationship-Test Issues

Relationship failures were encountered during development.

Instead of treating a failing test as something to remove immediately,
the project used the failure to investigate:

-   Whether the parent key was correct
-   Whether the child key contained invalid values
-   Whether nulls were expected
-   Whether the model grain was understood correctly
-   Whether filtering had removed valid parent records

## 5. Row-Count Validation

The Olist datasets have different source sizes and grains. Therefore,
row-count validation is performed around major transformations.

``` text
RAW
 |
 v
STAGING
 |
 v
INTERMEDIATE
 |
 v
MART
```

A changed row count is not necessarily an error. Joins and aggregations
can legitimately change the grain.

Unexpected multiplication, however, requires investigation.

## 6. Join-Cardinality Validation

A major issue identified was the geolocation join.

The geolocation dataset is not unique by ZIP-code prefix. Several
records can exist for the same prefix.

Directly joining it to order-level data therefore caused significant row
multiplication.

The project investigated row counts and identified that the geolocation
join was responsible for a large increase.

The correct engineering response is to understand the lookup grain and
aggregate or otherwise control it before joining.

## 7. Null and Invalid Data

The project also addressed invalid or missing source values.

Review data was examined for:

-   Invalid timestamps
-   Invalid review scores
-   Missing identifiers
-   CSV quoting/escaping and multiline issues

When an invalid value could not be reliably corrected, it was treated as
`NULL` rather than creating false information.

## 8. Snapshot Validation

The project contains:

``` text
snap_orders_timestamp.sql
snap_customers_check.sql
```

The customer snapshot uses:

``` text
customer_unique_id
```

as the unique key and checks selected attributes including:

``` text
customer_zip_code_prefix
customer_id
customer_state
```

Snapshots complement normal dbt tests by preserving selected historical
changes.

## 9. Testing Workflow

Typical commands:

``` powershell
dbt run
dbt test
dbt snapshot
```

Or:

``` powershell
dbt build
```

Testing was also used during troubleshooting of:

-   Null customer IDs
-   Relationship failures
-   Duplicate identifiers
-   Data-type errors
-   Date handling
-   Incorrect uniqueness assumptions

## 10. Testing Principles

1.  Establish model grain before defining tests.
2.  Test business keys according to actual uniqueness.
3.  Validate relationships only where they are genuinely expected.
4.  Use accepted-value tests for controlled fields.
5.  Validate record counts between pipeline stages.
6.  Investigate unexpected row multiplication.
7.  Treat invalid data explicitly.
8.  Keep data-quality rules close to the models they validate.

The objective is meaningful data quality, not simply obtaining a
successful `dbt test` result.
