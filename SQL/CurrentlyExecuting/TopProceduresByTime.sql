SELECT TOP(25) p.name AS [SP Name], 
qs.total_worker_time AS [TotalWorkerTime], qs.total_worker_time/qs.execution_count AS [AvgWorkerTime], 
qs.execution_count, ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count AS [avg_elapsed_time], qs.last_elapsed_time,
qs.cached_time
FROM sys.procedures AS p
INNER JOIN sys.dm_exec_procedure_stats AS qs
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_worker_time DESC;