
{% macro classify_customer(total_orders) %}

    case 

        when {{ total_orders }} = 1 
            then 'One-Time Customer'

        when {{ total_orders }} between 2 and 5 
            then 'Returning Customer'

        when {{ total_orders }} > 5 
            then 'Loyal Customer'

        else 'Unknown'

    end

{% endmacro %}