# Incremental Model --- Olist Snowflake + dbt

## 1. Purpose

The project includes an incremental sales model to demonstrate how dbt
can process new or changed records without rebuilding the entire target
table on every run.

Model:

``` text
fct_sales_incremental
```

## 2. Full vs Incremental Processing

Full rebuild:

``` text
Source
  |
  v
Transform ALL records
  |
  v
Rebuild target
```

Incremental processing:

``` text
Source
  |
  +--> New / Changed records
              |
              v
       Incremental model
              |
              v
       Merge into target
```

Incremental processing becomes increasingly valuable as data volume
grows.

## 3. Configuration

The model uses dbt incremental materialization and the following unique
key:

``` sql
{{ config(
    materialized='incremental',
    unique_key='sales_sk'
) }}
```

The exact incremental configuration must remain aligned with the model's
grain and change-detection strategy.

## 4. Unique Key --- sales_sk

The incremental model uses:

``` text
sales_sk
```

as its `unique_key`.

The key must identify one logical target record. This is why a
sales-level key is preferable to using a customer identifier for the
incremental sales table.

## 5. Incremental Filtering

dbt provides `is_incremental()` to apply logic only when the model is
running incrementally.

Conceptually:

``` sql
{% if is_incremental() %}

    -- select new or changed records

{% endif %}
```

A timestamp-based strategy can compare source updates with the latest
value already stored in the target:

``` sql
{% if is_incremental() %}

where updated_at > (
    select max(updated_at)
    from {{ this }}
)

{% endif %}
```

The actual source timestamp must reliably represent record changes.

## 6. Development Finding: Updated Source Record

During development, a source timestamp was moved forward by
approximately one day to simulate an updated record.

The full `fct_sales` model reflected the change, but
`fct_sales_incremental` initially remained unchanged.

This demonstrated the difference between rebuilding a model and applying
an incremental filter.

``` text
Full fct_sales
    |
    +--> Reprocesses source
    +--> Sees updated record

fct_sales_incremental
    |
    +--> Applies incremental selection
    +--> Can miss a record if the filter/change-detection logic is incomplete
```

The exercise highlighted that incremental processing is not merely a
materialization choice; the selection logic must correctly identify
changed records.

## 7. Late-Arriving Records

A production-oriented incremental strategy should consider:

-   New records
-   Updated records
-   Late-arriving records
-   Duplicate records
-   Timestamp precision
-   Null timestamps
-   Time-zone consistency

A simple `updated_at > max(updated_at)` condition may require additional
design when data can arrive late or timestamps are not reliably
maintained.

## 8. Merge Behaviour

With a valid `unique_key`, dbt can use merge-style behaviour:

``` text
Source record
     |
     v
Does sales_sk exist?
   /         Yes        No
 |           |
Update      Insert
```

This allows existing records to be updated and new records to be
inserted.

## 9. Full Refresh

When incremental logic or upstream transformation logic changes
substantially, the target can be rebuilt.

``` powershell
dbt run --select fct_sales_incremental --full-refresh
```

A full refresh should be used deliberately because it removes the normal
incremental-processing benefit for that run.

## 10. Validation

After modifying source data, compare the full and incremental models.

Example:

``` sql
select *
from fct_sales
where sales_sk = '<test-key>';
```

and:

``` sql
select *
from fct_sales_incremental
where sales_sk = '<test-key>';
```

Validate:

-   Record existence
-   Updated timestamp
-   Sales values
-   Freight values
-   Customer/product/seller keys

## 11. Development Workflow

``` text
1. Build full transformation
        |
        v
2. Validate model grain
        |
        v
3. Define unique_key
        |
        v
4. Implement incremental filter
        |
        v
5. Run initial incremental build
        |
        v
6. Modify source/new data
        |
        v
7. Run incremental model
        |
        v
8. Verify new/updated records
        |
        v
9. Test edge cases
```

## 12. Key Lessons

The incremental-model exercise demonstrated that a reliable
implementation requires:

-   Correct model grain
-   Stable unique key
-   Reliable change-detection column
-   Correct incremental filter
-   Appropriate merge behaviour
-   Validation of new and updated records
-   A planned full-refresh strategy

The model therefore serves as a practical demonstration of scalable ELT
processing in Snowflake with dbt.
