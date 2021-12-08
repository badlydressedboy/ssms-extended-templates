

--CACHED OBJECTS RESTRICTED BY DN NAME
select object_name(st.objectid), db_name(st.dbid) ,*
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(plan_handle) st
JOIN sys.dm_os_memory_objects AS omo --possibly not that useful
    ON cp.memory_object_address = omo.memory_object_address 
    OR cp.memory_object_address = omo.parent_address
where db_name(st.dbid) = 'RePro_prod'
--ORDER BY object_name(st.objectid)
ORDER BY USECOUNTS DESC



--cached procedure stats
SELECT --s.*--d.object_id, d.database_id, s.name, s.type_desc, d.cached_time, d.last_execution_time, d.total_elapsed_time, d.total_elapsed_time/d.execution_count AS [avg_elapsed_time], d.last_elapsed_time, d.execution_count
	p.name, p.schema_id, p.create_date, p.modify_date
	, eps.cached_time
	, last_execution_time
	, execution_count
	, total_worker_time
	, last_worker_time
	, min_worker_time
	, max_worker_time
	, total_physical_reads
	, last_physical_reads
	, min_physical_reads
	, max_physical_reads
	, total_logical_writes
	, last_logical_writes
	, min_logical_writes
	, max_logical_writes
	, total_logical_reads
	, last_logical_reads
	, min_logical_reads
	, max_logical_reads
	, total_elapsed_time
	, last_elapsed_time
	, min_elapsed_time
	, max_elapsed_time	
FROM sys.procedures p
INNER JOIN sys.dm_exec_procedure_stats eps
ON p.object_id = eps.object_id
ORDER BY 
	last_elapsed_time
	--total_worker_time 
DESC


--statistics for cached query plans. 
--One row per query statement within the cached plan
select * from sys.dm_exec_query_stats

SELECT query_stats.query_hash AS "Query Hash", 
    SUM(query_stats.total_worker_time) / SUM(query_stats.execution_count) AS "Avg CPU Time",
    MIN(query_stats.statement_text) AS "Statement Text"
FROM 
    (SELECT QS.*, 
    SUBSTRING(ST.text, (QS.statement_start_offset/2) + 1,
    ((CASE statement_end_offset 
        WHEN -1 THEN DATALENGTH(st.text)
        ELSE QS.statement_end_offset END 
            - QS.statement_start_offset)/2) + 1) AS statement_text
     FROM sys.dm_exec_query_stats AS QS
     CROSS APPLY sys.dm_exec_sql_text(QS.sql_handle) as ST) as query_stats
GROUP BY query_stats.query_hash
ORDER BY 2 DESC