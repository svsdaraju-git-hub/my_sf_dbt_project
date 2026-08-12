-- Silver layer: cleaned payroll fact with typed amounts and dates
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='payroll_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'payroll') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(payroll_id)                                    AS payroll_id,
        TRIM(person_id)                                     AS person_id,
        TRY_TO_DATE(pay_period_start, 'YYYY-MM-DD')        AS pay_period_start,
        TRY_TO_DATE(pay_period_end, 'YYYY-MM-DD')          AS pay_period_end,
        TRY_CAST(gross_salary AS NUMBER(12,2))              AS gross_salary,
        TRY_CAST(deductions AS NUMBER(12,2))                AS deductions,
        TRY_CAST(net_salary AS NUMBER(12,2))                AS net_salary,
        TRY_TO_DATE(pay_date, 'YYYY-MM-DD')                AS pay_date,
        _loaded_at,
        CURRENT_TIMESTAMP()                                 AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
