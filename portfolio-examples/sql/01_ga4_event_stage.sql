-- Portfolio demonstration: transform GA4 daily export tables into a clean event layer.
-- Replace project/dataset/property placeholders and choose a bounded date range.
-- GA4 daily tables are named events_YYYYMMDD. This example omits intraday tables.

DECLARE start_suffix STRING DEFAULT '20261101';
DECLARE end_suffix   STRING DEFAULT '20261130';

CREATE OR REPLACE TABLE `YOUR_PROJECT.analytics_mart.stg_ga4_events`
PARTITION BY event_date
CLUSTER BY event_name, session_key AS
WITH source_events AS (
  SELECT
    PARSE_DATE('%Y%m%d', event_date) AS event_date,
    TIMESTAMP_MICROS(event_timestamp) AS event_ts,
    user_pseudo_id,
    event_name,
    (SELECT ep.value.int_value
     FROM UNNEST(event_params) ep
     WHERE ep.key = 'ga_session_id'
     LIMIT 1) AS ga_session_id,
    (SELECT ep.value.string_value
     FROM UNNEST(event_params) ep
     WHERE ep.key = 'page_location'
     LIMIT 1) AS page_location,
    session_traffic_source_last_click.manual_campaign.source AS session_source,
    session_traffic_source_last_click.manual_campaign.medium AS session_medium,
    session_traffic_source_last_click.manual_campaign.campaign_name AS session_campaign
  FROM `YOUR_PROJECT.analytics_PROPERTY_ID.events_*`
  WHERE _TABLE_SUFFIX BETWEEN start_suffix AND end_suffix
)
SELECT
  event_date,
  event_ts,
  user_pseudo_id,
  ga_session_id,
  IF(user_pseudo_id IS NULL OR ga_session_id IS NULL, NULL,
     CONCAT(user_pseudo_id, '.', CAST(ga_session_id AS STRING))) AS session_key,
  event_name,
  page_location,
  COALESCE(session_source, '(not set)') AS session_source,
  COALESCE(session_medium, '(not set)') AS session_medium,
  COALESCE(session_campaign, '(not set)') AS session_campaign
FROM source_events;
