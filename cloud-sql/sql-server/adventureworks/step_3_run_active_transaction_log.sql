DECLARE @transaction_logs_retention_time INT = 3600;
EXEC [dbo].[SetUpDatastreamJob] @transaction_logs_retention_time = @transaction_logs_retention_time;