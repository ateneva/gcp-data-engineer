# BigQuery Setup

- [BigQuery Setup](#bigquery-setup)
  - [Gemini permissions](#gemini-permissions)
  - [Dataform permissions](#dataform-permissions)
  - [BQ Antipatterns](#bq-antipatterns)
  - [BQ best practices](#bq-best-practices)

## Gemini permissions

Gemini in BQ requires the following permissions

```bash
cloudaicompanion.entitlements.get
cloudaicompanion.instances.completeCode
cloudaicompanion.instances.completeTask
cloudaicompanion.instances.generateCode
cloudaicompanion.operations.get
cloudaicompanion.topics.create
```

## Dataform permissions

```bash
roles/bigquery.dataEditor
roles/bigquery.jobUser
roles/bigquery.dataViewer
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
