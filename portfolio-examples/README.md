# Marketing Analytics Portfolio Examples

A small, public-safe demonstration pack for marketing analytics work. The CSV rows and dashboard figures in this folder are synthetic examples created for demonstration; they are not client data or reported client results.

## Contents

- `sql/01_ga4_event_stage.sql` - GA4 BigQuery export to a cleaned event staging table.
- `sql/02_session_funnel_mart.sql` - Session-level funnel mart from the staging table.
- `python/campaign_etl.py` - CSV cleanup, validation, aggregation, and KPI calculation with pandas.
- `data/sample_campaign_data.csv` - Synthetic source data used by the Python script and dashboard preview.
- `dashboard/index.html` - Small interactive dashboard preview with a channel filter.
- `dashboard/measure_catalog.dax` - Example Power BI measures for a campaign scorecard.
- `dashboard/dashboard_spec.md` - Suggested Power BI page layout, model, and KPI definitions.

## BigQuery flow

GA4's native export loads event data into BigQuery. The SQL examples transform that exported data into a clean staging table and then a session-level reporting mart. This is an ELT-style workflow: raw data is already in BigQuery before the SQL transformations run.

Before running the SQL, replace the project, dataset, table, and event-name placeholders. The examples assume standard GA4 BigQuery export fields and a website using `cta_click`, `form_start`, and `form_submit_success` custom events. Adjust event names and parameters to match your implementation.

## Run the Python example

Install pandas, then run from this folder:

```bash
python -m pip install pandas
python python/campaign_etl.py --input data/sample_campaign_data.csv --output output/campaign_summary.csv
```

The script validates columns, parses dates, normalizes text, flags duplicate grain rows, aggregates to date/channel/campaign, and calculates CTR, CPC, CPL, cost per qualified lead, click-to-conversion rate, and ROAS.

## View the dashboard

Open `dashboard/index.html` in a browser. It reads the sample CSV values embedded in the page, so no server or external library is required. The channel selector filters the KPI cards and table.

## Add it to the portfolio homepage

From your repository root `index.html`, add links like these where you want the examples to appear:

```html
<h2>Analytics code and dashboard</h2>
<ul>
  <li><a href="portfolio-examples/sql/01_ga4_event_stage.sql">BigQuery event staging SQL</a></li>
  <li><a href="portfolio-examples/sql/02_session_funnel_mart.sql">BigQuery session funnel mart</a></li>
  <li><a href="portfolio-examples/python/campaign_etl.py">Python campaign ETL example</a></li>
  <li><a href="portfolio-examples/dashboard/index.html">Interactive dashboard preview</a></li>
  <li><a href="portfolio-examples/dashboard/dashboard_spec.md">Power BI dashboard design</a></li>
</ul>
```

## Notes

- These are portfolio demonstrations, not production client scripts.
- Do not add credentials, API keys, customer data, or confidential client exports to a public repository.
- The BigQuery scripts create/replace example output tables; review and replace the destination before running them in a real project.
