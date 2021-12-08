-- Top Cached SPs By Total Physical Reads (SQL 2008 only) 
-- Physical reads relate to disk I/O pressure
SELECT TOP(25) p.name AS [SP Name],qs.total_physical_reads AS [TotalPhysicalReads], 
qs.total_physical_reads/qs.execution_count AS [AvgPhysicalReads], qs.execution_count, 
ISNULL(qs.execution_count/DATEDIFF(Second, qs.cached_time, GETDATE()), 0) AS [Calls/Second],
qs.total_elapsed_time, qs.total_elapsed_time/qs.execution_count 
AS [avg_elapsed_time], qs.cached_time 
FROM sys.procedures AS p
INNER JOIN sys.dm_exec_procedure_stats AS qs
ON p.[object_id] = qs.[object_id]
WHERE qs.database_id = DB_ID()
ORDER BY qs.total_physical_reads DESC;
--qs.total_logical_reads DESC;

