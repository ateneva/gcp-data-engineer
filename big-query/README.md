# BigQuery Setup

- [BigQuery Setup](#bigquery-setup)
  - [Setting up Gemini in BigQuery](#setting-up-gemini-in-bigquery)
  - [Setting up Dataform in BigQuery](#setting-up-dataform-in-bigquery)
  - [Setting up INFORMATION\_SCHEMA access](#setting-up-information_schema-access)
    - [Identifying most expensive jobs](#identifying-most-expensive-jobs)
  - [BQ Antipatterns](#bq-antipatterns)
  - [BQ best practices](#bq-best-practices)

## Setting up Gemini in BigQuery

Gemini in BQ requires the following permissions

```bash
cloudaicompanion.entitlements.get
cloudaicompanion.instances.completeCode
cloudaicompanion.instances.completeTask
cloudaicompanion.instances.generateCode
cloudaicompanion.operations.get
cloudaicompanion.topics.create
```

## Setting up Dataform in BigQuery

```bash
roles/bigquery.dataEditor
roles/bigquery.jobUser
roles/bigquery.dataViewer
```

## [Setting up INFORMATION_SCHEMA access](https://cloud.google.com/bigquery/docs/information-schema-tables#advanced_example)

```bash
roles/bigquery.admin
roles/bigquery.dataViewer
roles/bigquery.metadataViewer
```

### Identifying most expensive jobs

```sql
SELECT
  job_id,
  user_email,
  job_type,
  statement_type,
  creation_time,
  start_time,
  end_time,
  state,
  total_bytes_processed,

  --cost in USD for reservation (capacity) pricing
  total_slot_ms,
  SAFE_DIVIDE(total_slot_ms, 1000 * 60 * 60) AS slot_hours_consumed,
  total_slot_ms/(1000 * 60 * 60)* 0.052 AS cost_in_dollars,

  --cost in USD for on-deamnd pricing
  total_bytes_billed,
  SAFE_DIVIDE(total_bytes_billed, POWER(2, 40)) * 6.25 AS estimated_cost_usd,
  query

FROM
  `data-geeking-gcp.region-eu.INFORMATION_SCHEMA.JOBS_BY_PROJECT`
WHERE creation_time >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)
  AND job_type = 'QUERY'
  AND state = 'DONE'
  AND error_result IS NULL
ORDER BY
  estimated_cost_usd DESC
```

## BQ Antipatterns

- query does not start with the largest table
- query does not use partitioning or clustering
- query does not result in partition pruning
- query does not filter data out as early as possible
- query does not scan minimum number of shards/ partitions possible
- query is not pre-computing heavy operations before joining on heavy tables
- query uses self-joins on large tables instead of window functions
- query does unnecessary sorting
- query results in data skew that is ovrerwhelming a single worker

## BQ best practices

- use partitioning and clustering to optimize query performance
- ensure partition pruning is in place and reduces the amount of data scanned
- filter data out as early as possible in the query
- start the query with the largest table to optimize join performance
- pre-compute heavy operations before joining on heavy tables
- use window functions instead of self-joins on large tables
- avoid unnecessary sorting in the query
- monitor query performance and adjust as needed to avoid data skew and optimize resource usage
- use materialized views or pre-aggregated tables for frequently accessed data to improve query performance
