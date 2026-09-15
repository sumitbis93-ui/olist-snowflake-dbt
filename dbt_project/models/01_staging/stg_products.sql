with source as (

    select *
    from {{ source('olist_raw', 'raw_products') }}

),

renamed as (

    select

        trim(product_id) as product_id,

        nullif(trim(product_category_name), '')
            as product_category_name,

        to_number(product_name_length)
            as product_name_length,

        to_number(product_description_length)
            as product_description_length,

        to_number(product_photos_qty)
            as product_photos_qty,

        to_decimal(product_weight_g, 18, 2)
            as product_weight_g,

        to_decimal(product_length_cm, 18, 2)
            as product_length_cm,

        to_decimal(product_height_cm, 18, 2)
            as product_height_cm,

        to_decimal(product_width_cm, 18, 2)
            as product_width_cm

    from source

)

select *
from renamed
