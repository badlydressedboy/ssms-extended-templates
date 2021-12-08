--wait type reference: http://msdn.microsoft.com/en-us/library/ms179984.aspx

--All waits by total wait time
select wait_type, wait_time_ms AS total_wait_time_ms, waiting_tasks_count, max_wait_time_ms, signal_wait_time_ms
from sys.dm_os_wait_stats
order by wait_time_ms DESC

--Lock waits by max wait
select wait_type, max_wait_time_ms, wait_time_ms AS total_wait_time_ms, waiting_tasks_count, signal_wait_time_ms
from sys.dm_os_wait_stats
--where wait_type like 'LCK%'
order by max_wait_time_ms DESC

--CLEAR THE CONTENTS OF THE VIEW:
--DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR);


-- Total waits are wait_time_ms (high signal waits indicates CPU pressure)
--useful to help confirm CPU pressure. Signal waits are time waiting for a CPU to service a thread. Seeing total signal waits above roughly 10-15% is a pretty good indicator of CPU pressure, although you should be aware of what your baseline value for signal waits is, and watch the trend over time.
SELECT CAST(100.0 * SUM(signal_wait_time_ms)/ SUM (wait_time_ms)AS NUMERIC(20,2)) 
AS [%signal (cpu) waits],
CAST(100.0 * SUM(wait_time_ms - signal_wait_time_ms) / SUM (wait_time_ms) AS NUMERIC(20,2)) 
AS [%resource waits]
FROM sys.dm_os_wait_stats;


-- top waits since server restart or stats clear
WITH Waits AS
(SELECT wait_type, wait_time_ms / 1000. AS wait_time_s,
100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN ('CLR_SEMAPHORE','LAZYWRITER_SLEEP','RESOURCE_QUEUE','SLEEP_TASK'
,'SLEEP_SYSTEMTASK','SQLTRACE_BUFFER_FLUSH','WAITFOR', 'LOGMGR_QUEUE','CHECKPOINT_QUEUE'
,'REQUEST_FOR_DEADLOCK_SEARCH','XE_TIMER_EVENT','BROKER_TO_FLUSH','BROKER_TASK_STOP','CLR_MANUAL_EVENT'
,'CLR_AUTO_EVENT','DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT'
,'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN'))
SELECT W1.wait_type, 
CAST(W1.wait_time_s AS DECIMAL(12, 2)) AS wait_time_s,
CAST(W1.pct AS DECIMAL(12, 2)) AS pct,
CAST(SUM(W2.pct) AS DECIMAL(12, 2)) AS running_pct
FROM Waits AS W1
INNER JOIN Waits AS W2
ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct
HAVING SUM(W2.pct) - W1.pct < 95; -- percentage threshold 