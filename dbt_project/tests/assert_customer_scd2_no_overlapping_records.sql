with customer_history as (

    select

        customer_unique_id,

        valid_from,

        valid_to

    from {{ ref('dim_customer_scd2') }}

),

ordered as (

    select

        *,

        lag(valid_to) over (

            partition by customer_unique_id

            order by valid_from

        ) as previous_valid_to

    from customer_history

)

select *

from ordered

where previous_valid_to is not null

  and valid_from < previous_valid_to
