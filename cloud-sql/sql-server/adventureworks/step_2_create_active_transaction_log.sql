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