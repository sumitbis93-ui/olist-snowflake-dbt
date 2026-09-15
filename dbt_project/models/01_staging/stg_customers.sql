with source as (
    select * 
        from {{ source('olist_raw', 'raw_customers') }}
),

renamed as (

    select 
        trim(customer_id) as customer_id,
        trim(customer_unique_id) as customer_unique_id,
        try_to_number(customer_zip_code_prefix) as customer_zip_code_prefix,
        trim(customer_city) as customer_city,
        upper(trim(customer_state)) as customer_state
            from source

)

select *
    from renamed