-- Silver layer: cleaned hiring details with typed dates
-- Co-authored with CoCo
{{
  config(
    materialized='incremental',
    unique_key='hiring_id',
    incremental_strategy='merge'
  )
}}

WITH source AS (
    SELECT * FROM {{ source('hrdt_raw', 'hiring_details') }}
    {% if is_incremental() %}
      WHERE _loaded_at > (SELECT MAX(_loaded_at) FROM {{ this }})
    {% endif %}
),

cleaned AS (
    SELECT
        TRIM(hiring_id)                                     AS hiring_id,
        TRIM(person_id)                                     AS person_id,
        TRIM(NULLIF(recruiter_name, ''))                    AS recruiter_name,
        TRIM(source)                                        AS hire_source,
        TRY_TO_DATE(hiring_date, 'YYYY-MM-DD')             AS hiring_date,
        TRY_TO_DATE(offer_accept_date, 'YYYY-MM-DD')       AS offer_accept_date,
        TRY_TO_DATE(joining_date, 'YYYY-MM-DD')            AS joining_date,
        _loaded_at,
        CURRENT_TIMESTAMP()                                 AS _transformed_at
    FROM source
)

SELECT * FROM cleaned
