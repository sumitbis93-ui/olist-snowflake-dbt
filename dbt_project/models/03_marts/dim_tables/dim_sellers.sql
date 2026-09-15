with sellers as (
    select *
        from {{ ref('stg_sellers') }}
),

geolocation as (
    select * 
        from {{ ref('stg_geolocation') }}
)

select 
        {{ 
            dbt_utils.generate_surrogate_key(
                ['s.seller_id']
            )
         }} as seller_sk,

        s.seller_id,
        s.seller_city,
        s.seller_state,
        s.seller_zip_code_prefix,

        g.geolocation_lat,
        g.geolocation_lng

    from
        sellers s 
            left join geolocation g
                on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix