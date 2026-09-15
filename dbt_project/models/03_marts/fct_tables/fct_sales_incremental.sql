{{ config(
    materialized = 'incremental',
    unique_key = 'sales_sk',
    incremental_strategy = 'merge'
) }}

SELECT *
FROM {{ ref('fct_sales') }}

{% if is_incremental() %}

WHERE order_date >= (
    SELECT MAX(order_date)
    FROM {{ this }}
)

{% endif %}