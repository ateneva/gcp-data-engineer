# AdventureWorks DW 2017 SQL Server Setup

This Terraform configuration creates a Google Cloud SQL instance for SQL Server 2017 and imports the AdventureWorksDW2017 database from a `.bak` file stored in Google Cloud Storage.

## Resources Created

- **Google Cloud SQL Instance**: SQL Server 2017 Standard edition.
- **SQL User**: A superuser (`sqlserver`) with a randomly generated password.
- **IAM Binding**: Grants the Cloud SQL service account read access to the GCS bucket containing the `.bak` file.
- **Import Job**: Uses `gcloud sql import bak` to restore the database.

## Usage

1.  Initialize Terraform:
    ```bash
    terraform init
    ```

2.  Apply the configuration:
    ```bash
    terraform apply
    ```

3.  The import process is handled via a `null_resource` using `local-exec`. Ensure you have `gcloud` authenticated and configured with the correct project.

## Note on SQL Server Tiers

SQL Server requires more resources than MySQL or PostgreSQL. This configuration uses `db-custom-2-3840` (2 vCPUs, 3.75 GB RAM) as a minimum viable tier for development.

## Get generated credentials

```bash
# 1. Print the generated password from your Terraform state
terraform output -raw sa_password
```

## Datastream to BigQuery Setup (CDC)

To stream changes from this SQL Server instance to BigQuery using Datastream, follow these steps:

### 1. Enable CDC on the Database

Connect to your SQL Server instance and run the following commands to enable Change Data Capture (CDC) and set up the necessary permissions.

```sql
-- 1. Enable CDC for the database
EXEC msdb.dbo.gcloudsql_cdc_enable_db 'AdventureWorksDW2017';

-- 2. Enable CDC for specific tables (e.g., DimCustomer)
USE [AdventureWorksDW2017];
EXEC sys.sp_cdc_enable_table 
    @source_schema = N'dbo', 
    @source_name = N'DimCustomer', 
    @role_name = NULL;

-- 3. Enable Snapshot Isolation for consistent backfills
ALTER DATABASE AdventureWorksDW2017 SET ALLOW_SNAPSHOT_ISOLATION ON;
```

### 2. Configure Transaction Log Retention

Datastream requires the transaction logs to be retained long enough to process changes.

```sql
USE [AdventureWorksDW2017];
-- Set polling interval to 24 hours (86399 seconds)
EXEC sys.sp_cdc_change_job @job_type = 'capture', @pollinginterval = 86399;
EXEC sys.sp_cdc_stop_job 'capture';
EXEC sys.sp_cdc_start_job 'capture';
```

#### Step 1 :

```sql
CREATE PROCEDURE dbo.DatastreamLogTruncationSafeguard @transaction_logs_retention_time INT
AS
BEGIN

DECLARE @transactionLog TABLE (beginLSN BINARY(10), endLSN BINARY(10))
INSERT @transactionLog EXEC sp_repltrans

DECLARE @currentDateTime DATETIME = GETDATE()
DECLARE @cutoffDateTime DATETIME = DATEADD(MINUTE, -@transaction_logs_retention_time, @currentDateTime)

DECLARE @firstValidLSN BINARY(10) = NULL
DECLARE @lastValidLSN BINARY(10) = NULL
DECLARE @firstTxnTime DATETIME = NULL
DECLARE @lastTxnTime DATETIME = NULL

SELECT TOP 1
    @lastTxnTime = t.logStartTime,
    @lastValidLSN = t.beginLSN
FROM (
  SELECT
    beginLSN AS beginLSN,
    (SELECT TOP 1 [begin time]
    FROM fn_dblog(stuff(stuff(CONVERT(CHAR(24), beginLSN, 1), 19, 0, ':'), 11, 0, ':'), DEFAULT)) AS logStartTime
  FROM @transactionLog
) t
ORDER BY t.beginLSN DESC

-- If all transactions are before cutoff, clear everything
IF (@lastTxnTime < @cutoffDateTime)
BEGIN
    EXEC sp_repldone NULL, NULL, 0, 0, 1
END
ELSE
BEGIN
    -- Find the earliest transaction
    SELECT TOP 1
      @firstTxnTime = t.logStartTime,
      @firstValidLSN = ISNULL(@firstValidLSN, t.beginLSN)
    FROM (
      SELECT
        beginLSN AS beginLSN,
        (SELECT TOP 1 [begin time]
        FROM fn_dblog(stuff(stuff(CONVERT(CHAR(24), beginLSN, 1), 19, 0, ':'), 11, 0, ':'), DEFAULT)) AS logStartTime
      FROM @transactionLog
    ) t
    ORDER BY t.beginLSN ASC

    IF (@firstTxnTime < @cutoffDateTime)
    BEGIN
        -- Identify the earliest and latest LSNs within VLogs before cutoff
        SELECT
          @firstValidLSN = SUBSTRING(MAX(t.lsnMarkers), 1, 10),
          @lastValidLSN = SUBSTRING(MAX(t.lsnMarkers), 11, 10)
        FROM (
          SELECT MIN(beginLSN + endLSN) AS lsnMarkers
          FROM @transactionLog
          GROUP BY SUBSTRING(beginLSN, 1, 4)
        ) t
        WHERE (
          SELECT TOP 1 [begin time]
          FROM fn_dblog(stuff(stuff(CONVERT(CHAR(24), SUBSTRING(t.lsnMarkers, 1, 10), 1), 19, 0, ':'), 11, 0, ':'), DEFAULT)
          WHERE Operation = 'LOP_BEGIN_XACT'
        ) < @cutoffDateTime

        EXEC sp_repldone @firstValidLSN, @lastValidLSN, 0, 0, 0
    END
  END
END;
```

#### Step 2:

```sql
CREATE PROCEDURE [dbo].[SetUpDatastreamJob] @transaction_logs_retention_time INT
AS
BEGIN

DECLARE @database_name VARCHAR(MAX)
  SET @database_name =  (SELECT DB_NAME());;

  DECLARE @command_str VARCHAR(MAX);
  SET @command_str = CONCAT('Use ', @database_name,'; exec dbo.DatastreamLogTruncationSafeguard @transaction_logs_retention_time = ' + CAST(@transaction_logs_retention_time AS VARCHAR(10)));

  DECLARE @job_name VARCHAR(MAX);
SET @job_name =
  CONCAT(@database_name, '_', 'DatastreamLogTruncationSafeguardJob1')
    DECLARE @current_time INT
  = CAST(FORMAT(GETDATE(), 'HHmmss') AS INT);

  -- Schedule the procedure to run after every 5 minutes.
  IF NOT EXISTS (
    SELECT * FROM msdb.dbo.sysjobs
    WHERE name = @job_name
  )
  BEGIN
    EXEC msdb.dbo.sp_add_job
    @job_name = @job_name,
    @enabled = 1,
    @description = N'Execute the procedure every 5 minutes.' ;

    EXEC msdb.dbo.sp_add_jobstep
    @job_name =  @job_name,
    @step_name = N'Execute_DatastreamLogTruncationSafeguard',
    @subsystem = N'TSQL',
    @command = @command_str;

      DECLARE @schedule_name_1 VARCHAR(MAX);
    SET @schedule_name_1 = CONCAT(@database_name, '_', 'DatastreamEveryFiveMinutesSchedule')

    EXEC msdb.dbo.sp_add_schedule
    @schedule_name = @schedule_name_1,
    @freq_type = 4,  -- daily start
    @freq_subday_type = 4,  -- every X minutes daily
    @freq_interval = 1,
    @freq_subday_interval = 5,
    @active_start_time = @current_time;

    EXEC msdb.dbo.sp_attach_schedule
    @job_name = @job_name,
    @schedule_name = @schedule_name_1 ;

    -- Add a schedule that runs the stored procedure on the SQL Server Agent startup.
    DECLARE @schedule_name_agent_startup VARCHAR(MAX);
    SET @schedule_name_agent_startup = CONCAT(@database_name, '_', 'DatastreamSqlServerAgentStartupSchedule')

    EXEC msdb.dbo.sp_add_schedule
    @schedule_name = @schedule_name_agent_startup,
    @freq_type = 64,  -- start on SQL Server Agent startup
    @active_start_time = @current_time;

    EXEC msdb.dbo.sp_attach_schedule
    @job_name = @job_name,
    @schedule_name = @schedule_name_agent_startup ;

    EXEC msdb.dbo.sp_add_jobserver
    @job_name = @job_name,
    @server_name = @@servername ;
  END
END;
```

#### Step 3:

```sql
DECLARE @transaction_logs_retention_time INT = 3600;
EXEC [dbo].[SetUpDatastreamJob] @transaction_logs_retention_time = @transaction_logs_retention_time;
```

### 3. Networking

1.  **Public IP**: The Terraform configuration in `main.tf` automatically adds Datastream's regional IP addresses for `europe-west1` to the **Authorized Networks** for your Cloud SQL instance. If you are using a different region, you must update the IP list in `main.tf`.


2.  **Private IP**: If using a private network, you must set up a **Private Service Connect (PSC)** or **VPC Peering** connection profile in Datastream.


### 4. Datastream Infrastructure

The `datastream.tf` file (if provided) contains the Terraform resources to create:
- A **Source Connection Profile** for SQL Server.
- A **Destination Connection Profile** for BigQuery.
- A **Stream** that captures changes from the enabled tables.

### 5. Start the Stream

Once the infrastructure is deployed and CDC is enabled, start the stream in the GCP Console to begin the initial backfill and ongoing change synchronization.

