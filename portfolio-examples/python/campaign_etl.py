"""Portfolio demo: clean campaign exports and create a KPI summary.

Input grain: one row per date, channel, campaign. Duplicate rows are flagged
and combined so the output is one row per date/channel/campaign.
The included CSV is synthetic demonstration data, not client data.
"""
from __future__ import annotations

import argparse
from pathlib import Path
import pandas as pd

KEYS = ["date", "channel", "campaign"]
METRICS = ["spend", "impressions", "clicks", "leads", "qualified_leads", "conversions", "revenue"]
REQUIRED = KEYS + METRICS


def safe_divide(numerator: pd.Series, denominator: pd.Series) -> pd.Series:
    return numerator.div(denominator.where(denominator.ne(0)))


def transform(input_path: Path) -> pd.DataFrame:
    df = pd.read_csv(input_path)
    missing = sorted(set(REQUIRED) - set(df.columns))
    if missing:
        raise ValueError(f"Missing required columns: {', '.join(missing)}")

    df = df[REQUIRED].copy()
    df["date"] = pd.to_datetime(df["date"], errors="coerce").dt.date
    for column in METRICS:
        df[column] = pd.to_numeric(df[column], errors="coerce")

    bad_dates = int(df["date"].isna().sum())
    bad_metric_rows = int(df[METRICS].isna().any(axis=1).sum())
    if bad_dates or bad_metric_rows:
        raise ValueError(
            f"Data quality check failed: {bad_dates} invalid dates; "
            f"{bad_metric_rows} rows with missing/non-numeric metrics."
        )
    if (df[METRICS] < 0).any().any():
        raise ValueError("Negative values found in non-negative campaign metrics.")

    df["channel"] = df["channel"].astype("string").str.strip().str.lower()
    df["campaign"] = df["campaign"].astype("string").str.strip()
    if df["channel"].eq("").any() or df["campaign"].eq("").any():
        raise ValueError("Blank channel or campaign names found.")

    duplicate_rows = int(df.duplicated(KEYS, keep=False).sum())
    if duplicate_rows:
        print(f"Review note: {duplicate_rows} rows share the declared input grain; aggregating them.")

    summary = (
        df.groupby(KEYS, as_index=False, dropna=False)[METRICS]
        .sum()
        .sort_values(KEYS)
    )
    summary["ctr"] = safe_divide(summary["clicks"], summary["impressions"])
    summary["cpc"] = safe_divide(summary["spend"], summary["clicks"])
    summary["cpl"] = safe_divide(summary["spend"], summary["leads"])
    summary["cost_per_qualified_lead"] = safe_divide(
        summary["spend"], summary["qualified_leads"]
    )
    summary["click_to_conversion_rate"] = safe_divide(
        summary["conversions"], summary["clicks"]
    )
    summary["roas"] = safe_divide(summary["revenue"], summary["spend"])
    return summary


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", type=Path, required=True, help="Source campaign CSV")
    parser.add_argument("--output", type=Path, required=True, help="Destination summary CSV")
    args = parser.parse_args()

    result = transform(args.input)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    result.to_csv(args.output, index=False)
    print(f"Wrote {len(result)} campaign/date rows to {args.output}")


if __name__ == "__main__":
    main()
