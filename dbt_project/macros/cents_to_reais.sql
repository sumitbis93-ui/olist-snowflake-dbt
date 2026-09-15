
{% macro cents_to_reais(column_name) %}

    ({{column_name}} / 100.0)

{% endmacro %}