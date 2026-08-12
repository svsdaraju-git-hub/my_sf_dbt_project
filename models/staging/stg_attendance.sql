-- Silver layer: cleaned attendance fact with typed timestamps
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='attendance_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'attendance') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(attendance_id)                                 AS attendance_id,
        TRIM(person_id)                                     AS person_id,
        TRY_TO_DATE(work_date, 'YYYY-MM-DD')               AS work_date,
        TRY_TO_TIMESTAMP(check_in_time, 'YYYY-MM-DD HH24:MI:SS')  AS check_in_time,
        TRY_TO_TIMESTAMP(check_out_time, 'YYYY-MM-DD HH24:MI:SS') AS check_out_time,
        TRY_CAST(hours_worked AS NUMBER(5,2))               AS hours_worked,
        UPPER(TRIM(status))                                 AS status,
        _loaded_at,
        CURRENT_TIMESTAMP()                                 AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
