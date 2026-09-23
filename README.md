# SQL Analytics Toolkit

![CI](https://github.com/geethalakshmi579/sql-analytics-toolkit/actions/workflows/ci.yml/badge.svg)

A portfolio demo of the analytics SQL patterns I use most in data engineering
and solutions work: cohort retention, funnel conversion, window-function
revenue analytics, and a data-quality assertion suite. Everything runs on
**SQLite** (zero setup) against a **synthetic** e-commerce dataset.

![SQLite](https://img.shields.io/badge/SQLite-003B57?style=flat-square&logo=sqlite&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.10%2B-3776AB?style=flat-square&logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)

> All data is fictional, generated deterministically (`seed=42`) by
> `data/generate.py`. Nothing here is real customer data.

## What's inside

| Script | Pattern | Why it matters |
|---|---|---|
| `sql/01_schema.sql` | Star-ish schema, indexes, constraints | The foundation every analysis sits on |
| `sql/02_cohort_retention.sql` | Monthly signup cohorts × activity grid | Retention is the metric behind growth |
| `sql/03_funnel_analysis.sql` | Channel funnel: signup → first order → repeat | Where acquisition spend actually converts |
| `sql/04_window_functions.sql` | Running totals, MoM growth, top-N per group, LTV | The workhorse of revenue reporting |
| `sql/05_data_quality.sql` | 7 assertions (orphans, dupes, nulls, bad dates) | Trust the numbers before presenting them |

## Run it

```bash
python3 data/generate.py   # builds data/*.csv + analytics.db (~2,500 orders)
python3 run_all.py         # executes every script, checks the DQ suite
```

Expected: all checks `PASS`, and the data-quality suite returns zero violations.

## Sample output

```
[PASS] 02_cohort_retention.sql — cohort retention grid (75 rows)
[PASS] 03_funnel_analysis.sql — channel funnel (5 rows)
       ('social', 99, 98, 99.0, 93, 94.9)
       ('organic', 80, 80, 100.0, 74, 92.5)
       ...
[PASS] 04_window_functions.sql — window analytics (3 statements) (68 rows)
[PASS] 05_data_quality.sql — data-quality assertions (0 rows)
```

## Notes

- Written in portable SQL (SQLite dialect); the patterns translate directly to
  Postgres, BigQuery, Snowflake, and Spark SQL / Databricks.
- The generator enforces referential integrity, so the DQ suite is green by
  construction — break the data on purpose to watch the assertions fire.

## Author

**Geetha Gunda** — Solutions Engineer working on cloud data & lakehouse
platforms (Databricks, AWS, Delta Lake, Spark, SQL, Python).
