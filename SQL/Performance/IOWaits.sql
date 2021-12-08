--IO waits   
--problem if your waiting_task_counts and wait_time_ms  change significantly from what you see normally. 
--It is important to get a baseline of performance counters and key DMV query outputs when SQL Server is running smoothly.   
select wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms, wait_time_ms / waiting_tasks_count
from sys.dm_os_wait_stats  
where wait_type like 'PAGEIOLATCH%'  and waiting_tasks_count > 0
order by wait_type   


--PENDING IO requests
--The query usually returns nothing in the normal situation. You need to investigate further if this query returns some rows.
select 
    database_id, 
    file_id, 
    io_stall,
    io_pending_ms_ticks,
    scheduler_address 
from  sys.dm_io_virtual_file_stats(NULL, NULL)t1,
        sys.dm_io_pending_io_requests as t2
where t1.file_handle = t2.io_handle 


-- Look at pending I/O requests by file
SELECT DB_NAME(mf.database_id) AS [Database], mf.physical_name, 
r.io_pending, r.io_pending_ms_ticks, r.io_type, fs.num_of_reads, fs.num_of_writes
FROM sys.dm_io_pending_io_requests AS r
INNER JOIN sys.dm_io_virtual_file_stats(null,null) AS fs
ON r.io_handle = fs.file_handle 
INNER JOIN sys.master_files AS mf
ON fs.database_id = mf.database_id
AND fs.file_id = mf.file_id
ORDER BY r.io_pending, r.io_pending_ms_ticks DESC; 