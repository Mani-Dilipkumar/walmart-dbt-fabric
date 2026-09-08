{% set configs = [
    {
        "table": ref('customers_t'),
        "columns": """c.customer_id,
                      c.first_name AS customer_first_name,
                      c.last_name AS customer_last_name,
                      c.email AS customer_email,
                      c.phone AS customer_phone,
                      c.city AS customer_city,
                      c.province AS customer_province,
                      c.country AS customer_country,
                      c.created_timestamp AS customer_created_timestamp,
                      c.updated_timestamp AS customer_updated_timestamp,
                      c.is_active AS customer_is_active
                   """,
        "alias": "c"
    },
    {
        "table": ref('stores_t'),
        "columns": """s.store_id,
                      s.store_name,
                      s.city AS store_city,
                      s.province AS store_province,
                      s.country AS store_country,
                      s.created_timestamp AS store_created_timestamp,
                      s.updated_timestamp AS store_updated_timestamp,
                      s.is_active AS store_is_active
                   """,
        "alias": "s",
        "join_condition": "c.city = s.city AND c.country = s.country"
    },
    {
        "table": ref('employees_t'),
        "columns": """e.employee_id,
                      e.first_name AS employee_first_name,
                      e.last_name AS employee_last_name,
                      e.email AS employee_email,
                      e.job_title,
                      e.salary,
                      e.created_timestamp AS employee_created_timestamp,
                      e.updated_timestamp AS employee_updated_timestamp,
                      e.is_active AS employee_is_active
                   """,
        "alias": "e",
        "join_condition": "s.store_id = e.store_id"
    }
] %}

SELECT
    {% for config in configs %}
        {{ config['columns'] }}{% if not loop.last %},{% endif %}
    {% endfor %}
FROM
    {% for config in configs %}
        {% if loop.first %}
            {{ config['table'] }} AS {{ config['alias'] }}
        {% else %}
LEFT JOIN
            {{ config['table'] }} AS {{ config['alias'] }}
            ON {{ config['join_condition'] }}
        {% endif %}
    {% endfor %}
