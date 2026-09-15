with source as (

    select *
    from {{ source('olist_raw', 'raw_geolocation') }}

),

cleaned as (

    select
        try_to_number(geolocation_zip_code_prefix) as geolocation_zip_code_prefix,
        cast(geolocation_lat as float) as geolocation_lat,
        geolocation_lng::float as geolocation_lng,
        trim(geolocation_city) as geolocation_city,
        upper(trim(geolocation_state)) as geolocation_state

    from source

),

deduplicated as (

    select

        geolocation_zip_code_prefix,
        avg(geolocation_lat) as geolocation_lat,
        avg(geolocation_lng) as geolocation_lng,
        max(geolocation_city) as geolocation_city,
        max(geolocation_state) as geolocation_state

    from cleaned
    group by geolocation_zip_code_prefix

)

select *
from deduplicated