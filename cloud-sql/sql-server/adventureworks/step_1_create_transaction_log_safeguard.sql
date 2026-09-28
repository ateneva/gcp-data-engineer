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