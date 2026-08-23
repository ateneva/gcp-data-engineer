---
name: cloud-sql-provisioner
description: Autogenerates Terraform files to create Google Cloud SQL instances and import data from GCS. Use when the user needs to provision new databases or migrate data into Cloud SQL using Terraform.
---

# Cloud SQL Provisioner

## Overview

This skill helps Gemini CLI generate idiomatic Terraform configurations for provisioning Cloud SQL instances and importing data from Google Cloud Storage (GCS). It ensures best practices like using random suffixes for instance names and handling IAM permissions for data imports.

## Workflow

When asked to create a Cloud SQL instance and import data:

1. **Identify Database Requirements**: Determine the database type (MySQL, PostgreSQL, SQL Server), version, and region.

2. **Locate Source Data**: Identify the GCS bucket and file paths for the data to be imported.

3. **Generate Terraform**: Create `main.tf`, `variables.tf`, and `import.tf` based on the patterns in [terraform-patterns.md](references/terraform-patterns.md).

4. **Grant Permissions**: Ensure the Cloud SQL service account is granted `roles/storage.objectViewer` on the source bucket.

5. **Implement Import**: Use `null_resource` with `local-exec` to trigger `gcloud sql import`.

## Guidelines

- **Instance Naming**: Always use `random_id` to append a suffix to the instance name to avoid collisions and allow for rapid re-provisioning.

- **Security**: Use `random_password` for the database user. Avoid hardcoding credentials.

- **Import Strategy**: Prefer `gcloud sql import` over other methods for large SQL dumps as it is managed by the GCP backend.

- **Dependencies**: Ensure the import resource `depends_on` the instance, database, and IAM grant.

## Reference Patterns

Detailed code examples for various scenarios can be found in [references/terraform-patterns.md](references/terraform-patterns.md).
