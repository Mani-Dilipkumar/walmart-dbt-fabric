SELECT 
    DISTINCT
    employee_id,
    employee_first_name,
    employee_last_name,
    employee_email,
    job_title,
    salary,
    store_id,
    employee_created_timestamp,
    employee_updated_timestamp,
    employee_is_active
FROM 
    {{ ref('obt_b') }}
ORDER BY 
employee_id
