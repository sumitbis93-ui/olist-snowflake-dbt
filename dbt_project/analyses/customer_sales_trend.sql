select

    customer_unique_id,

    count(distinct order_id)
        as total_orders,

    sum(item_total_value)
        as lifetime_sales,

    avg(average_review_score)
        as average_review_score,

    max(order_date)
        as last_order_date

from {{ ref('fct_sales') }}

group by customer_unique_id

order by lifetime_sales desc
