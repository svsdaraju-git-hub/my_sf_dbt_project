-- Silver layer: cleaned learning enrollments with typed dates
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='enrollment_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'learning_enrollments') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(enrollment_id)                         AS enrollment_id,
        TRIM(person_id)                             AS person_id,
        TRIM(course_id)                             AS course_id,
        TRIM(course_name)                           AS course_name,
        TRY_TO_DATE(enroll_date, 'YYYY-MM-DD')     AS enroll_date,
        UPPER(TRIM(status))                         AS status,
        _loaded_at,
        CURRENT_TIMESTAMP()                         AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
