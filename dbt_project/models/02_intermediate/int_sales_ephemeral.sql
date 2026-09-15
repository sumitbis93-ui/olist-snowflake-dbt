{{ config(
    materialized = 'ephemeral'
) }}

SELECT
    sales_sk,
    order_id,
    customer_id,
    product_id,
    seller_id,
    order_date,
    order_status,
    price,
    freight_value,

    -- Calculate total sales
    COALESCE(price, 0) + COALESCE(freight_value, 0) AS total_sales,

    CASE
        WHEN COALESCE(price, 0) + COALESCE(freight_value, 0) >= 500
            THEN 'High Value'

        WHEN COALESCE(price, 0) + COALESCE(freight_value, 0) >= 100
            THEN 'Medium Value'

        ELSE 'Low Value'
    END AS sales_value_category

FROM {{ ref('fct_sales') }}