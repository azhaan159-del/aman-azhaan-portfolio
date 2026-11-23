# Power BI dashboard starter

## Purpose

A campaign performance dashboard that helps a marketing stakeholder see spend, outcomes, efficiency, and the campaigns behind movement. The accompanying CSV is synthetic demonstration data; it is not a client export or client result.

## Suggested model

Load `../data/sample_campaign_data.csv` as a table named `Campaigns`.

- Set `date` to Date.
- Set spend and revenue to Decimal Number / Currency as appropriate.
- Set impressions, clicks, leads, qualified leads, and conversions to Whole Number.
- Add a Date table and relate `Date[Date]` to `Campaigns[date]` if you want a proper time intelligence model.
- Use the measures in `measure_catalog.dax` for KPI cards and visuals.

## Page layout

1. **KPI row:** Spend, Revenue, ROAS, Leads, Cost per Qualified Lead.
2. **Trend:** Spend and conversions by date.
3. **Channel comparison:** Spend, leads, qualified leads, CPL, and ROAS by channel.
4. **Campaign table:** Campaign, spend, clicks, leads, qualified leads, conversions, revenue, CPL, and ROAS.
5. **Filters:** Date and channel; optionally campaign.

## Reading the metrics

- CTR = clicks / impressions.
- CPL = spend / leads.
- Cost per qualified lead = spend / qualified leads.
- Click-to-conversion rate = conversions / clicks.
- ROAS = revenue / spend.

Use `DIVIDE` in DAX so a zero denominator returns blank instead of an error. Treat platform-reported conversions as platform-attributed results; they do not establish incrementality by themselves.

## Validation checklist

- Confirm date range and currency.
- Confirm campaign names and channel labels are standardized.
- Compare totals with source exports after aligning attribution windows and definitions.
- Check that totals respond as expected to each slicer.
- Label synthetic examples as demonstration data when sharing the report.
