select 
object_name(object_id) as proc_name,last_execution_time, cached_time, execution_count, total_worker_time--, *
from sys.dm_exec_procedure_stats  
where database_ID = db_id()
order by last_execution_time desc


