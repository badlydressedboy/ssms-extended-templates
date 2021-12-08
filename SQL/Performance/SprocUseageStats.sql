--2008+-----------------------------------------------------
select 
--type_desc
--, last_execution_time
--, [text]
OBJECT_SCHEMA_NAME(object_id,database_id) AS [SCHEMA_NAME] 
, object_name(objectid) as name
, plan_handle
, cached_time
, last_execution_time
, total_worker_time
,execution_count
,total_logical_reads/execution_count AS [avg_logical_reads]
,total_physical_reads/execution_count AS [avg_physical_reads]	
,total_logical_reads
,total_physical_reads
,min_worker_time
,max_worker_time	
,total_worker_time / execution_count AS avg_cpu
,total_elapsed_time / execution_count AS avg_elapsed
,total_logical_reads / execution_count AS avg_logical_reads
,total_logical_writes / execution_count AS avg_logical_writes
,total_physical_reads  / execution_count AS avg_physical_reads  
FROM sys.dm_exec_procedure_stats sp
	OUTER APPLY sys.dm_exec_sql_text (sp.plan_handle) as sql_text
WHERE database_id = db_id()
	AND type = 'P'
ORDER BY last_execution_time desc

--2005--------------------------------------------------------
--possibly drill down from this aggregated view to lower level
SELECT 
      OBJECT_SCHEMA_NAME(objectid,dbid) AS [SCHEMA_NAME] 
      ,OBJECT_NAME(objectid,dbid)AS [OBJECT_NAME]
      ,MAX(qs.creation_time) AS 'cached_time'
      ,MAX(last_execution_time) AS 'last_execution_time'
      ,MAX(usecounts) AS [execution_count]
      ,SUM(total_worker_time) / SUM(usecounts) AS avg_cpu
      ,SUM(total_elapsed_time) / SUM(usecounts) AS avg_elapsed
      ,SUM(total_logical_reads) / SUM(usecounts) AS avg_logical_reads
      ,SUM(total_logical_writes) / SUM(usecounts) AS avg_logical_writes
      ,SUM(total_physical_reads) / SUM(usecounts)AS avg_physical_reads       
FROM sys.dm_exec_query_stats qs 
   join sys.dm_exec_cached_plans cp on qs.plan_handle = cp.plan_handle
   CROSS APPLY sys.dm_exec_sql_text(cp.plan_handle)
WHERE objtype = 'Proc'
	AND text
       NOT LIKE '%CREATE FUNC%'
	AND dbid = db_id()
	GROUP BY cp.plan_handle,DBID,objectid 