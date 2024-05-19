SELECT
    deqs.creation_time,
    dest.text AS [SQL_Text]
FROM sys.dm_exec_query_stats AS deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
WHERE dest.text LIKE '%US_InvioEmail_Queue_01%'
ORDER BY deqs.creation_time DESC;
