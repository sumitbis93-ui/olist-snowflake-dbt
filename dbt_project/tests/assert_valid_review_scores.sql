select *

from {{ ref('fct_sales') }}

where average_review_score < 1
   or average_review_score > 5
