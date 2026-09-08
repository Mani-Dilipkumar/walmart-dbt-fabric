{{
config(
    materialized='incremental',
    unique_key='order_id')   
}}

SELECT * 
FROM
    {{source('bronze', 'bronze_orders')}}

{% if is_incremental() %}
    WHERE updated_timestamp > (SELECT COALESCE(MAX(updated_timestamp), '1900-01-01') FROM {{ this }})
{% endif %}