-- Silver layer: cleaned working hours fact with typed numerics
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='working_hour_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'working_hours') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(working_hour_id)                           AS working_hour_id,
        TRIM(person_id)                                 AS person_id,
        TRY_TO_DATE(week_start_date, 'YYYY-MM-DD')     AS week_start_date,
        TRY_CAST(total_hours AS NUMBER(5,2))            AS total_hours,
        TRY_CAST(overtime_hours AS NUMBER(5,2))         AS overtime_hours,
        UPPER(TRIM(shift_type))                         AS shift_type,
        _loaded_at,
        CURRENT_TIMESTAMP()                             AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
