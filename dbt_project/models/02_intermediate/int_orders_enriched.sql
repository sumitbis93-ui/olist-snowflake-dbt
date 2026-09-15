with orders as (
    select * 
        from {{ ref('stg_orders') }}
),

payments as (

    select 
            order_id,
            sum(payment_value) as total_payment_value,
            count(*) as payment_count,
            max(payment_installments) as max_payment_installments
        from
            {{ ref('stg_order_payments') }}
                group by order_id

),

reviews as (

    select
            order_id,
            round(avg(coalesce(review_score, 0)), 1) as average_review_score,
            count(*) as review_count
        from 
            {{ ref('stg_order_reviews') }}
                group by order_id
),

customers as (
    select * 
        from {{ ref('stg_customers') }}
)

select 
        
        o.order_id,

        o.customer_id,

        cu.customer_unique_id,
        cu.customer_city,
        cu.customer_state,

        o.order_status,

        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_carrier_date,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,

        datediff(
            'days',
            o.order_purchase_timestamp,
            o.order_delivered_customer_date
        ) as delivery_days,

        datediff(
            'days',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date
        ) as delivery_variance_days,

        p.total_payment_value,
        p.payment_count,
        p.max_payment_installments,

        r.average_review_score,
        r.review_count
    
    from orders o 

        left join customers cu 
            on o.customer_id = cu.customer_id

        left join payments p 
            on o.order_id = p.order_id

        left join reviews r 
            on o.order_id = r.order_id