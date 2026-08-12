-- Silver layer: cleaned location dimension with standardized address fields
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='location_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'location') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(location_id)                       AS location_id,
        TRIM(location_name)                     AS location_name,
        TRIM(NULLIF(address_line1, ''))          AS address_line1,
        TRIM(NULLIF(address_line2, ''))          AS address_line2,
        INITCAP(TRIM(city))                     AS city,
        UPPER(TRIM(state))                      AS state,
        TRIM(postal_code)                       AS postal_code,
        UPPER(TRIM(country))                    AS country,
        _loaded_at,
        CURRENT_TIMESTAMP()                     AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
