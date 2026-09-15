
select *
    from {{ ref('fct_sales') }}
where 
    abs(
        item_total_value - (price + freight_value)
    ) > 0.01