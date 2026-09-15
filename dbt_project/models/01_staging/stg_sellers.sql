with source as (

    select *
    from {{ source('olist_raw', 'raw_sellers') }}

),

renamed as (

    select

        trim(seller_id) as seller_id,
        try_to_number(seller_zip_code_prefix) as seller_zip_code_prefix,
        trim(seller_city) as seller_city,
        upper(trim(seller_state)) as seller_state

    from source

)

select *
from renamed