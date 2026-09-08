SELECT 
    DISTINCT
    store_id,
    store_name,
    store_city,
    store_province,
    store_country,
    store_created_timestamp,
    store_updated_timestamp,
    store_is_active,
    CAST(SYSDATETIME() AS DATETIME2(6)) AS store_gold_processed_at

FROM 
    {{ ref('obt_b') }}

ORDER BY store_id