with order_payments as (

    select
        *
    from {{ source('olist_raw', 'raw_order_payments') }}

),

valid_orders as (

    select
        order_id
    from {{ ref('stg_orders') }}

)

select
        trim(op.order_id) as order_id,
        to_number(op.payment_sequential) as payment_sequential,
        lower(trim(op.payment_type)) as payment_type,
        try_to_number(op.payment_installments) as payment_installments,
        to_decimal(op.payment_value, 18, 2) as payment_value

from order_payments op
    
    inner join valid_orders o
        
        on op.order_id = o.order_id