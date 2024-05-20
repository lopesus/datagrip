--coda
SELECT * FROM  InvioEmailQueue

--delete coda
    DELETE  from InvioEmailQueue

-- noti

SELECT * FROM dbo.AUTO_NOTIFICATION

--
EXEC UI_InvioEmail_Queue_01 @IdBatchParameter = 1

--
EXEC  US_InvioEmail_Queue_01 @IdBatchParameter = 1