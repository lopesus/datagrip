SELECT
    deqs.creation_time,
    dest.text AS [SQL_Text]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%US_InvioEmail_Queue_01%'
ORDER BY deqs.creation_time DESC
;-- -. . -..- - / . -. - .-. -.--
--
CREATE PROCEDURE [dbo].[US_InvioEmail_Queue_01] @IdBatchParameter INT
AS

DECLARE @MaxRecordsCount INT;
DECLARE @AvailableRecordsCount INT;
DECLARE @RecordsCount INT;
DECLARE @ExpiryTimestamp INT;
DECLARE @AttemptsCount INT;

    SET NOCOUNT ON;
/*
Dalla tab ApplicationParameter con Context = 'EMARCA_ELABORAZIONI_BATCH' AND Enabled = 1
estrae @MaxRecordsCount numero massimo record da estrarre, @ExpiryTimestamp tempo di validità, @AttemptsCount numero massimo tentativi
*/

SELECT @MaxRecordsCount = MAX(MaxRow),
       @ExpiryTimestamp = MAX(ExpiryTimestamp),
       @AttemptsCount = MAX(AttemptsCount)
FROM dbo.ApplicationParameter
         PIVOT
         (
         MAX(Value)
         FOR Name IN ([MaxRow], [ExpiryTimestamp], [AttemptsCount])
         ) AS ValuesTable
WHERE Context = 'EMARCA_ELABORAZIONI_BATCH_INVIO_EMAIL'
  AND Enabled = 1

-- conta i record NON scaduti , (sono quelli in corso di lavorazione) e popola la variabile @RecordsCount
SELECT @RecordsCount = COUNT(*)
FROM dbo.InvioEmailQueue WITH (NOLOCK)
WHERE ExpiryTimestamp > GETDATE()
  AND AttemptsCount > 0;

-- calcola il numero di record da mandare al batch e popola la variabile @AvailableRecordsCount
    SET @AvailableRecordsCount = @MaxRecordsCount - @RecordsCount;

-- se @AvailableRecordsCount < zero allora @AvailableRecordsCount = 0
    IF @AvailableRecordsCount < 0
        SET @AvailableRecordsCount = 0


UPDATE
    TOP (@AvailableRecordsCount) dbo.InvioEmailQueue WITH (UPDLOCK, READPAST)
SET AttemptsCount   = AttemptsCount + 1,
    ExpiryTimestamp = DATEADD(SS, @ExpiryTimestamp, GETDATE())
OUTPUT inserted.*

WHERE ExpiryTimestamp <= GETDATE()
  AND AttemptsCount < @AttemptsCount
  AND IdBatchParameter = @IdBatchParameter
;-- -. . -..- - / . -. - .-. -.--
DELETE  from InvioEmailQueue
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM dbo.AUTO_NOTIFICATION
;-- -. . -..- - / . -. - .-. -.--
EXEC UI_InvioEmail_Queue_01 @IdBatchParameter = 1
;-- -. . -..- - / . -. - .-. -.--
SELECT * FROM  InvioEmailQueue
;-- -. . -..- - / . -. - .-. -.--
EXEC  US_InvioEmail_Queue_01 @IdBatchParameter = 1