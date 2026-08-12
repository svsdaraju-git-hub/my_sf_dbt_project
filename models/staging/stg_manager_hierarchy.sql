-- Silver layer: cleaned manager hierarchy with typed level
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='person_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'manager_hierarchy') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(person_id)                     AS person_id,
        TRIM(NULLIF(manager_id, ''))        AS manager_id,
        TRY_CAST(level_no AS INTEGER)       AS level_no,
        _loaded_at,
        CURRENT_TIMESTAMP()                 AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
