-- Silver layer: cleaned business unit dimension
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='bu_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'business_unit') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(bu_id)                 AS bu_id,
        TRIM(bu_name)               AS bu_name,
        TRIM(bu_head)               AS bu_head,
        TRIM(bu_location)           AS bu_location,
        _loaded_at,
        CURRENT_TIMESTAMP()         AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
