# Cost Monitoring in Google Cloud (GCP)

- [Cost Monitoring in Google Cloud (GCP)](#cost-monitoring-in-google-cloud-gcp)
  - [1. Set Up Budgets and Spending Alerts (First Step)](#1-set-up-budgets-and-spending-alerts-first-step)
  - [2. Visualize Costs with Billing Reports \& Cost Explorer](#2-visualize-costs-with-billing-reports--cost-explorer)
  - [3. Export Billing Data to BigQuery for Deep Analysis](#3-export-billing-data-to-bigquery-for-deep-analysis)
  - [4. Leverage Active Recommendations](#4-leverage-active-recommendations)
  - [Summary](#summary)
  - [References](#references)

> Monitoring costs in Google Cloud (GCP) comes down to a few core built-in tools. Setting up an effective monitoring workflow usually involves setting up proactive alerts, tracking daily trends, and getting granular visibility into individual workloads.

---

## 1. Set Up Budgets and Spending Alerts (First Step)

Budget alerts notify you via email or webhook before you overspend.

1. Go to the *Google Cloud Console* and open *Billing*.
2. Click *Budgets & alerts* in the navigation menu.
3. Click *Create Budget*.
4. Set the scope: choose specific projects, billing accounts, or individual services.
5. Define the target amount (e.g., $500/month or based on previous month's spend).
6. Set threshold triggers (e.g., alert at 50%, 80%, 100% of budget, or forecasted 100%).
7. Add notification channels: standard email alerts, or connect a *Pub/Sub topic* to push alerts automatically to *Slack*, *PagerDuty*, or a Cloud Function.

> *Tip:* You can set budget alerts based on *forecasted spend*, which warns you halfway through the month if your current usage rate is projected to breach your limit.

---

## 2. Visualize Costs with Billing Reports & Cost Explorer

GCP provides visual dashboards natively in the console:

- *Billing Reports:* Navigate to *Billing > Reports*. Use the filters on the right pane to group costs by *Project*, *Service*, *SKU*, or *Region*.

- *GCP Cost Explorer:* Use the new *Cost Explorer* under Cloud Observability to inspect historical spend and resource utilization metrics for specific App Hub workloads or projects.

- *Label-Based Tracking:* Apply custom metadata labels to your GCP resources (e.g., `environment: production`, `team: backend`). You can filter Billing Reports by these labels to track spending by department or environment.

---

## 3. Export Billing Data to BigQuery for Deep Analysis

> The built-in reports are great for high-level numbers, but exporting to BigQuery unlocks custom queries and custom Looker Studio dashboards.

1. Go to *Billing > Billing Export*.

2. Enable *Standard usage cost export* and *Detailed usage cost export* (includes resource IDs and tags).

3. Select a BigQuery dataset as the destination.

4. Once set up, GCP streams every line-item transaction to BigQuery. You can query specific granular details using SQL (e.g., *"How much did our GKE clusters cost yesterday?"*) or plug the table directly into *Looker Studio* for automated interactive dashboards.

---

## 4. Leverage Active Recommendations

> GCP automatically scans your environment for underutilized or idle resources.

- Go to *Billing > Cost Optimization* (or visit the *Recommender* service).
- Review recommendations for *right-sizing overprovisioned VMs*, deleting idle disks/IP addresses, or purchasing *Committed Use Discounts (CUDs)* for steady-state workloads.

---

## Summary

| Tool | Primary Use Case | Output |
| --- | --- | --- |
| *Budgets & Alerts* | Catch runaway spending early | Email, Slack, or Pub/Sub alerts |
| *Billing Reports* | Track monthly spending trends and filter by service/project | Console charts & tables |
| *BigQuery Export* | Deep SQL analysis and custom reporting | BigQuery tables + Looker Studio dashboards |
| *Cost Optimization/Recommender* | Find quick cost-saving opportunities | Actionable recommendations (CUDs, right-sizing) |

## References

- <https://docs.cloud.google.com/billing/docs/how-to/export-data-bigquery-setup>

- <https://docs.cloud.google.com/billing/docs/how-to/export-data-bigquery-tables/focus-export>

- <https://docs.cloud.google.com/billing/docs/how-to/export-data-bigquery-tables/standard-usage>

- <https://docs.cloud.google.com/billing/docs/how-to/export-data-bigquery-tables/detailed-usage>
