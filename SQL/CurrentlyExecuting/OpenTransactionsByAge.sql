select datediff(ss,last_batch, getdate()) as age
, spid, blocked as blockedBy, db_name(sp.dbid) as dbname, loginame, hostname, program_name, text
, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, last_batch, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where 
	open_tran > 0	
order by datediff(ss,last_batch, getdate()) desc	