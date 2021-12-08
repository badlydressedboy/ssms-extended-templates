--select * from sys.dm_exec_query_stats
--beware - these do not cover ad-hoc queries as db_id is null
select sum(total_logical_reads) as query_logical_reads
from sys.dm_exec_query_stats

select sum(total_logical_reads) as procedure_logical_reads
from sys.dm_exec_procedure_stats

select sum(total_logical_reads) as trigger_logical_reads
from sys.dm_exec_trigger_stats


