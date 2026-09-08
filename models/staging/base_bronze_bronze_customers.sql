with source as (
        select * from {{ source('bronze', 'bronze_customers') }}
  ),
  renamed as (
      select
          {{ adapter.quote("customer_id") }},
        {{ adapter.quote("first_name") }},
        {{ adapter.quote("last_name") }},
        {{ adapter.quote("email") }},
        {{ adapter.quote("phone") }},
        {{ adapter.quote("city") }},
        {{ adapter.quote("province") }},
        {{ adapter.quote("country") }},
        {{ adapter.quote("created_timestamp") }},
        {{ adapter.quote("updated_timestamp") }},
        {{ adapter.quote("is_active") }},
        {{ adapter.quote("_ingested_at") }}

      from source
  )
  select * from renamed
    