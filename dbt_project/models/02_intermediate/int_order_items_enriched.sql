with order_items as (
    select *
    from {{ ref('stg_order_items') }}
),

orders as (
    select *
    from {{ ref('stg_orders') }}
),

products as (
    select *
    from {{ ref('stg_products') }}
),

categories as (
    select * 
    from {{ ref('stg_product_categories') }}
),

sellers as (
    select * 
    from {{ ref('stg_sellers') }}
),

customers as (
    select * 
    from {{ ref('stg_customers') }}
)

select 

    oi.order_id,

    oi.order_item_id,

    oi.product_id,

    oi.seller_id,

    oi.shipping_limit_date,

    oi.price,

    oi.freight_value,

    (oi.price + oi.freight_value) as item_total_value,

    o.customer_id,

    o.order_status,

    o.order_purchase_timestamp,

    p.product_category_name,

    coalesce(
        cat.product_category_name_english,
        p.product_category_name,
        'unknown'
    ) as product_category_name_english,

    p.product_weight_g,
    p.product_length_cm,
    p.product_width_cm,
    p.product_height_cm,

    s.seller_city,
    s.seller_state,

    cu.customer_unique_id,
    cu.customer_city,
    cu.customer_state

    from order_items oi 

        left join orders o 
            on oi.order_id = o.order_id

        left join products p 
            on oi.product_id = p.product_id

        left join categories cat 
            on p.product_category_name = cat.product_category_name

        left join sellers s 
            on oi.seller_id = s.seller_id

        left join customers cu 
            on o.customer_id = cu.customer_id
            