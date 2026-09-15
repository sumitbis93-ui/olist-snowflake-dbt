
with order_items as (

    select
        *
    from {{ source('olist_raw', 'raw_order_items') }}

),

valid_orders as (

    select
        order_id
    from {{ ref('stg_orders') }}

)

select
        trim(oi.order_id) as order_id,

        try_to_number(oi.order_item_id) as order_item_id,

        trim(oi.product_id) as product_id,

        trim(oi.seller_id) as seller_id,

        oi.shipping_limit_date as shipping_limit_date,

        to_double(oi.price) as price,

        to_double(oi.freight_value) as freight_value

from order_items oi

    inner join valid_orders o

        on oi.order_id = o.order_id
