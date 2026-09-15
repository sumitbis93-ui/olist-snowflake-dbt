with sales as (
    select * 
        from {{ ref('fct_sales') }}
)

select 
        order_date,
        product_category_name_english,
        customer_state,
        seller_state,

        count(distinct order_id) 
                as total_orders,

        count(*) 
                as total_items,

        sum(price) 
                as product_sales,

        sum(freight_value) 
                as freight_revenue,

        sum(item_total_value) 
                as gross_sales,

        avg(price) 
                as average_item_price,

        round(avg(average_review_score), 1)
                as average_review_score,

        round(avg(delivery_days), 1) 
                as average_delivery_days 

    from 
        sales
            group by 
                order_date,
                product_category_name_english,
                customer_state,
                seller_state

