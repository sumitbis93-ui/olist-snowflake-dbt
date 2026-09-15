with customer_history as (
    select *
        from {{ ref('snap_customers_check') }}
)

select 
        {{ 
           dbt_utils.generate_surrogate_key(
                ['customer_unique_id',
                 'customer_id',
                 'dbt_valid_from']
            ) 
         }} as customer_sk,
        customer_unique_id,
        customer_id,
        customer_zip_code_prefix,
        customer_city,
        customer_state,
        dbt_valid_from as valid_from,
        dbt_valid_to as valid_to,
        case 
            when dbt_valid_to is NULL
                then true 
            else false
        end as is_current
    from
        customer_history