-- Silver layer: cleaned merger history with typed date
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='merger_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'merger_history') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(merger_id)                                 AS merger_id,
        TRIM(bu_id)                                     AS bu_id,
        TRY_TO_DATE(merger_date, 'YYYY-MM-DD')         AS merger_date,
        TRIM(merger_details)                            AS merger_details,
        _loaded_at,
        CURRENT_TIMESTAMP()                             AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
