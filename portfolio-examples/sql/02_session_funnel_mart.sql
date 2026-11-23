-- Portfolio demonstration: create one row per session, then aggregate a funnel mart.
-- Assumes stg_ga4_events was created by 01_ga4_event_stage.sql.
-- Change custom event names to match your property's event taxonomy.

CREATE OR REPLACE TABLE `YOUR_PROJECT.analytics_mart.mart_session_funnel`
PARTITION BY session_date
CLUSTER BY session_source, session_medium, session_campaign AS
WITH session_rollup AS (
  SELECT
    session_key,
    MIN(event_date) AS session_date,
    ANY_VALUE(session_source) AS session_source,
    ANY_VALUE(session_medium) AS session_medium,
    ANY_VALUE(session_campaign) AS session_campaign,
    LOGICAL_OR(event_name = 'session_start') AS had_session_start,
    LOGICAL_OR(event_name = 'cta_click') AS had_cta_click,
    LOGICAL_OR(event_name = 'form_start') AS had_form_start,
    LOGICAL_OR(event_name = 'form_submit_success') AS had_form_submit
  FROM `YOUR_PROJECT.analytics_mart.stg_ga4_events`
  WHERE session_key IS NOT NULL
  GROUP BY session_key
)
SELECT
  session_date,
  session_source,
  session_medium,
  session_campaign,
  COUNTIF(had_session_start) AS sessions,
  COUNTIF(had_cta_click) AS cta_sessions,
  COUNTIF(had_form_start) AS form_start_sessions,
  COUNTIF(had_form_submit) AS successful_submit_sessions,
  SAFE_DIVIDE(COUNTIF(had_cta_click), COUNTIF(had_session_start)) AS session_to_cta_rate,
  SAFE_DIVIDE(COUNTIF(had_form_start), COUNTIF(had_cta_click)) AS cta_to_form_start_rate,
  SAFE_DIVIDE(COUNTIF(had_form_submit), COUNTIF(had_form_start)) AS form_start_to_submit_rate
FROM session_rollup
GROUP BY session_date, session_source, session_medium, session_campaign;
