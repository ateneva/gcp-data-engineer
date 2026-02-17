# BigQuery Setup

<!-- TOC -->

- [BigQuery Setup](#bigquery-setup)
    - [Gemini permissions](#gemini-permissions)
    - [Dataform permissions](#dataform-permissions)

<!-- /TOC -->

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
