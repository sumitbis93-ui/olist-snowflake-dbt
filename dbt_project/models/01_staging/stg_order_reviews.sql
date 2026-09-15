with order_reviews as (

    select
        *
    from {{ source('olist_raw', 'raw_order_reviews') }}

),

valid_orders as (

    select
        order_id
    from {{ ref('stg_orders') }}

)

select
        trim(r.review_id) as review_id,

        trim(r.order_id) as order_id,

        to_number(r.review_score) as review_score,

        trim(r.review_comment_title) as review_comment_title,

        trim(r.review_comment_message) as review_comment_message,

        to_timestamp_ntz(r.review_creation_date)
            as review_creation_date,

        to_timestamp_ntz(r.review_answer_timestamp)
            as review_answer_timestamp

from order_reviews r

    inner join valid_orders o

        on r.order_id = o.order_id