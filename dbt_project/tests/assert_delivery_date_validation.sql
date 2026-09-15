select *

from {{ ref('fct_sales') }}

where delivery_days < 0
