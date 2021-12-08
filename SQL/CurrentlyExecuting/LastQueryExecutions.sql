--all times in microseconds
select top(25)--* 
	last_execution_time	
	,last_worker_time as last_cpu_time
	,last_elapsed_time as last_total_exe_time
	,text 
	,creation_time
	,execution_count
	,total_worker_time
	,min_worker_time
	,max_worker_time
from sys.dm_exec_query_stats AS qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
order by 
	last_execution_time desc
	--last_elapsed_time desc
	
	
	
-- first find what is running and identify ones with big cpu time
sp_who2
sp_who2 active

dbcc opentran

sp_lock

--next see what command the spid in question issued
dbcc inputbuffer(148)


select * from sys.dm_exec_requests er
CROSS APPLY sys.dm_exec_sql_text(er.sql_handle) AS st



SELECT *--request_id 
FROM sys.dm_exec_requests 
--WHERE session_id = 204
order by start_time



	