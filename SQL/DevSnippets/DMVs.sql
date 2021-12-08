select * from sys.dm_db_session_space_usage 

select * from sys.dm_db_file_space_usage 

select * from sys.dm_exec_query_transformation_stats

select * from sys.dm_io_pending_io_requests

--select * from sys.dm_io_virtual_file_stats ??

--select * from sys.dm_db_index_operational_stats ??

select * from sys.dm_db_index_physical_stats

select OBJECT_NAME(object_id),db_NAME(database_id),* 
from sys.dm_db_index_usage_stats
order by user_scans desc

--select * from sys.dm_db_missing_index_columns ??

select * from sys.dm_db_missing_index_details

select * from sys.dm_db_missing_index_group_stats

select * from sys.dm_db_missing_index_groups

select * from sys.dm_exec_cached_plans

--select * from sys.dm_exec_cached_plan_dependent_objects ??

select * from sys.dm_exec_connections
order by connect_time desc

--select * from sys.dm_exec_cursors ?

select * from sys.dm_exec_query_optimizer_info

--select * from sys.dm_exec_query_plan ?

select * from sys.dm_exec_query_stats
order by last_execution_time desc

select * from sys.dm_exec_sessions
order by last_request_start_time desc

--select * from sys.dm_exec_sql_text ?

--select * from sys.dm_exec_text_query_plan

select * from 

select * from 

select * from 

select * from 