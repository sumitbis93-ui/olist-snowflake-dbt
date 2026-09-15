
with monthly_category_sales as (

    select 
            date_trunc(
                'month', order_date
            ) as sales_month,
            product_category_name_english as category,
            sum(item_total_value) as monthly_sales
        from  {{ ref('fct_sales') }}
            group by 1, 2

)

select 
        sales_month,
        category,
        monthly_sales,
        lag(monthly_sales) 
            over (partition by category order by sales_month)
                as previous_month_sales,
        round(
            {{ safe_divide(
            '(monthly_sales - previous_month_sales)',
            'previous_month_sales'
            ) }} * 100, 2
        )
            as month_over_month_growth_percentage
    from
        monthly_category_sales