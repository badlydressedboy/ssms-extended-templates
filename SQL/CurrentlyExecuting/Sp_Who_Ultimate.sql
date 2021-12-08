

--all processes
select spid, blocked as blockedBy, db_name(sp.dbid) as dbname, last_batch
, datediff(ss,last_batch, getdate()) as last_batch_age_secs
, loginame, hostname, program_name, text, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where db_name(sp.dbid) = db_name()
order by last_batch desc	


--active processes
select spid, blocked as blockedBy, db_name(sp.dbid) as dbname, last_batch
, datediff(ss,last_batch, getdate()) as last_batch_age_secs
, loginame, hostname, program_name, text, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where db_name(sp.dbid) = db_name()
and open_tran > 0 --currently active
order by last_batch desc	


--blocked
select spid, blocked as blockedBy, db_name(sp.dbid) as dbname, last_batch
, datediff(ss,last_batch, getdate()) as last_batch_age_secs
, loginame, hostname, program_name, text, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where db_name(sp.dbid) = db_name()
and blocked > 0
order by last_batch desc


--BLOCKER - top of the tree - there may be other blockers but this\these are the nonblocked ones.
select spid, blocked as blockedBy, db_name(sp.dbid) as dbname, last_batch
, datediff(m,last_batch, getdate()) as last_batch_age_secs
, loginame, hostname, program_name, text, stmt_start, stmt_end, cmd, lastwaittype, waitresource,  cpu as cpu_ms, physical_io, memusage, open_tran, status  
from sys.sysprocesses sp
CROSS APPLY sys.dm_exec_sql_text(sp.sql_handle) AS sq
where spid in
	(select blocked
	from sys.sysprocesses
	where blocked > 0)
and blocked = 0	
and db_name(sp.dbid) = db_name()
order by last_batch desc	





/*** STATUS VALUES ***
dormant = SQL Server is resetting the session.

running = The session is running one or more batches. When Multiple Active Result Sets (MARS) is enabled, a session can run multiple batches. For more information, see Using Multiple Active Result Sets (MARS).

background = The session is running a background task, such as deadlock detection.

rollback = The session has a transaction rollback in process.

pending = The session is waiting for a worker thread to become available.

runnable = The task in the session is in the runnable queue of a scheduler while waiting to get a time quantum.

spinloop = The task in the session is waiting for a spinlock to become free.

suspended = The session is waiting for an event, such as I/O, to complete.
*/






	