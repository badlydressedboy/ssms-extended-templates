-- Number of open transaction older than threshold

select spid, blocked as blockedBy, db_name(sp.dbid) as dbname, loginame, hostname, program_name, text, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, last_batch, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where 
	open_tran > 0
	AND last_batch < DATEADD(mm, -1, getdate())
	--AND db_name(sp.dbid) = db_name()	
order by last_batch desc	


