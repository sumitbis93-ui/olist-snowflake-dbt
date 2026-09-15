with order_items as (
    select * 
        from {{ ref('int_order_items_enriched') }}
),

orders as (
    select * 
        from {{ ref('int_orders_enriched') }} 
)

select 
        {{ 
            dbt_utils.generate_surrogate_key(
                ['oi.order_id',
                 'oi.order_item_id'
                ]
            ) 
        }} as sales_sk,

        oi.order_id,

        oi.order_item_id,

        oi.product_id,

        oi.seller_id,

        oi.customer_id,

        oi.customer_unique_id,

        oi.order_status,

        oi.order_purchase_timestamp,

        cast(
            oi.order_purchase_timestamp as date
        ) as order_date,

        oi.product_category_name,

        oi.product_category_name_english,

        oi.price,

        oi.freight_value,

        oi.item_total_value,

        oi.product_weight_g,

        oi.seller_city,

        oi.seller_state,

        oi.customer_city,

        oi.customer_state,

        orders.total_payment_value,

        orders.average_review_score,

        orders.delivery_days,

        orders.delivery_variance_days

    from  order_items oi 
        left join orders 
                on oi.order_id = orders.order_id

    --    where oi.customer_id is not null