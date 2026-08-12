-- Silver layer: cleaned position dimension
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='position_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'position') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(position_id)           AS position_id,
        TRIM(position_name)         AS position_name,
        TRIM(designation)           AS designation,
        TRIM(grade_level)           AS grade_level,
        TRIM(department)            AS department,
        _loaded_at,
        CURRENT_TIMESTAMP()         AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
