
select *
    from {{ ref('fct_sales') }}
where 
    order_date > current_date()