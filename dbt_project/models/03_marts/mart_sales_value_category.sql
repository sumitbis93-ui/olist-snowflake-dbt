{{ config(
    materialized = 'table'
) }}

SELECT
    sales_value_category,
    COUNT(*) AS sales_count,
    SUM(total_sales) AS total_sales,
    AVG(total_sales) AS average_sales

FROM {{ ref('int_sales_ephemeral') }}

GROUP BY
    sales_value_category