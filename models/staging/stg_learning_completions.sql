-- Silver layer: cleaned learning completions with typed dates
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='completion_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'learning_completions') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(completion_id)                             AS completion_id,
        TRIM(person_id)                                 AS person_id,
        TRIM(course_id)                                 AS course_id,
        TRIM(course_name)                               AS course_name,
        TRY_TO_DATE(enroll_date, 'YYYY-MM-DD')         AS enroll_date,
        TRY_TO_DATE(completion_date, 'YYYY-MM-DD')     AS completion_date,
        UPPER(TRIM(status))                             AS status,
        _loaded_at,
        CURRENT_TIMESTAMP()                             AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
