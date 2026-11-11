# Product analytics with SQL and Python

[**English**](README.md) · [Português (Brasil)](README.pt-BR.md)

Where do users drop out before creating their first project, and how many return in later weeks? This case study answers those questions for a fictional project-management app with **2,400 synthetic users**, three acquisition channels and eight signup cohorts.

## What the queries measure

- [Activation funnel](funnel.sql) counts signups, onboarding completions and first projects by acquisition channel. Stages must occur in order within seven calendar days, including signup day. The query includes users whose full seven-day window is observable.
- [Cohort retention](retention.sql) groups users by signup week (Monday to Sunday). A user counts as retained if they use a project at least once in a given later calendar week. The denominator is everyone who signed up in that cohort. Only complete weeks through March 9, 2025 appear in the output.

## Results

| Acquisition channel | Signups | Onboarded | Activated | Signup → activation |
| --- | ---: | ---: | ---: | ---: |
| Referral | 800 | 685 | 487 | 60.9% |
| Organic | 800 | 602 | 367 | 45.9% |
| Paid search | 800 | 542 | 250 | 31.3% |

Paid search loses 258 users before onboarding and 292 after onboarding. In a real product, the second drop would be a place to investigate what happens between onboarding and first project creation. Referral and paid search differ by 29.6 percentage points in signup-to-activation in this sample.

Among the five cohorts with a full fourth week of observation, week-four retention ranges from **11.7% to 17.7%**. The acquisition and return probabilities are inputs to the simulation, so these results illustrate the analysis workflow.

## Reproduce

Run `python run.py` with Python 3.11+. The script generates events with a fixed seed, loads the [SQLite schema](schema.sql) in memory and writes [funnel.csv](results/funnel.csv) and [retention.csv](results/retention.csv). It uses only Python's standard library.
