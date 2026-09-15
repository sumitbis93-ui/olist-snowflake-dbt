
select 

        date_trunc(
            'month',
            order_date
        ) as sales_month,

        to_char(
            date_trunc('month', order_date), 'YYYY-MM'
            ) as sales_month_label,

        count(distinct order_id) as total_orders, 

        sum(price) as product_sales,

        sum(freight_value) as freight_revenue,

        sum(item_total_value) as gross_sales,

        round(avg(average_review_score), 1) as average_review_score

    from 
        {{ ref('fct_sales') }}
            group by 1
            order by 1