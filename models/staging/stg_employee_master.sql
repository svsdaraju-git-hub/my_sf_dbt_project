{{
  config(
    materialized='incremental',
    unique_key='emp_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'employee_master') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        -- Primary key
        TRIM(emp_id)                                    AS emp_id,
        TRIM(emp_code)                                  AS emp_code,

        -- Name fields (cleaned)
        INITCAP(TRIM(legal_first_name))                 AS legal_first_name,
        INITCAP(TRIM(NULLIF(legal_middle_name, '')))    AS legal_middle_name,
        INITCAP(TRIM(legal_last_name))                  AS legal_last_name,
        INITCAP(TRIM(full_name))                        AS full_name,
        INITCAP(TRIM(first_name))                       AS first_name,
        INITCAP(TRIM(NULLIF(middle_name, '')))          AS middle_name,
        INITCAP(TRIM(last_name))                        AS last_name,

        -- Contact info
        LOWER(TRIM(work_email))                         AS work_email,
        LOWER(TRIM(NULLIF(personal_email, '')))         AS personal_email,
        TRIM(phone)                                     AS phone,

        -- Demographics
        UPPER(TRIM(gender))                             AS gender,
        TRY_TO_DATE(date_of_birth, 'YYYY-MM-DD')       AS date_of_birth,

        -- Employment
        UPPER(TRIM(emp_type))                           AS emp_type,
        UPPER(TRIM(status))                             AS status,
        TRY_TO_DATE(hire_date, 'YYYY-MM-DD')           AS hire_date,
        TRY_TO_DATE(NULLIF(termination_date, ''), 'YYYY-MM-DD') AS termination_date,

        -- Position & Organization
        TRIM(position_id)                               AS position_id,
        TRIM(designation)                               AS designation,
        TRIM(department)                                AS department,
        TRIM(bu_id)                                     AS bu_id,
        TRIM(location_id)                               AS location_id,
        TRIM(NULLIF(manager_id, ''))                    AS manager_id,
        TRY_CAST(manager_level AS INTEGER)              AS manager_level,

        -- Compensation
        TRIM(pay_grade)                                 AS pay_grade,
        TRY_CAST(salary AS NUMBER(12,2))                AS salary,
        UPPER(TRIM(bonus_eligible))                     AS bonus_eligible,
        TRIM(pay_frequency)                             AS pay_frequency,

        -- Banking (sensitive)
        TRIM(NULLIF(bank_account_no, ''))               AS bank_account_no,
        TRIM(NULLIF(bank_name, ''))                     AS bank_name,

        -- Compliance
        TRIM(work_auth_status)                          AS work_auth_status,
        TRIM(NULLIF(national_id, ''))                   AS national_id,
        TRIM(NULLIF(tax_id, ''))                        AS tax_id,

        -- Hiring
        TRIM(NULLIF(hire_source, ''))                   AS hire_source,
        TRIM(NULLIF(recruiter_name, ''))                AS recruiter_name,

        -- Metadata
        _loaded_at,
        CURRENT_TIMESTAMP()                             AS _transformed_at

    FROM source
)

SELECT * FROM cleaned
