
select * 
    from {{ ref('fct_sales') }}
where 
    item_total_value < 0     