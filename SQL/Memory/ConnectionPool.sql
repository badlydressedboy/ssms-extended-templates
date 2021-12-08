--connection pool size - things may get ropey\flakey after 3Gb...

SELECT SUM(single_pages_kb+multi_pages_kb)
AS "CurrentSizeOfTokenCache(kb)",@@SERVERNAME,GETDATE(),
(SELECT COUNT(*) FROM master.dbo.sysprocesses) AS Spid_Count
FROM sys.dm_os_memory_clerks
WHERE name='TokenAndPermUserStore'


--clear connection pool
--DBCC freesystemcache('TokenAndPermUserStore')

freesystempagetableentries



select * from sys.dm_os_performance_counters
where counter_name like '%entries%'