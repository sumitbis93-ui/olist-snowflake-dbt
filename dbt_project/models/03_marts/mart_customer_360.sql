with sales as (
    select * 
        from {{ ref('fct_sales') }}
),

customer_summary as (

    select 
        customer_unique_id,
        max(customer_city) as customer_city,
        max(customer_state) as customer_state,
        count(distinct order_id) as total_orders,
        count(*) as total_items,
        sum(item_total_value) as lifetime_value,
        avg(item_total_value) as average_order_item_value,
        round(avg(average_review_score), 1) as average_review_score,
        round(avg(delivery_days), 1) as average_delivery_days,
        min(order_date) as first_order_date,
        max(order_date) as last_order_date
    from
        sales
            group by customer_unique_id

)

select 
        customer_unique_id,
        customer_city,
        customer_state,
        total_orders,
        total_items,
        lifetime_value,
        average_order_item_value,
        average_review_score,
        average_delivery_days,
        first_order_date,
        last_order_date,
        {{ classify_customer('total_orders') }}
                as customer_segment
    from
        customer_summary