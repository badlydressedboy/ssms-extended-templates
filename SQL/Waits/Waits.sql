use master;    
                DECLARE @total_waits BIGINT
                SELECT @total_waits =SUM((wait_time_ms)) from sys.dm_os_wait_stats
                SELECT 
                    ISNULL(RTRIM(wait_type),'')
                    , CONVERT(decimal(4,2),(CAST((wait_time_ms) as decimal(19,2))/@total_waits) * 100) as PcOfAllWaitTime
                    , wait_time_ms	                
                    , signal_wait_time_ms
                    , max_wait_time_ms
                    , waiting_tasks_count		 
                FROM sys.dm_os_wait_stats
                where [wait_type] NOT IN 
				   ('XE_TIMER_EVENT', 'TRACEWRITE', 'MISCELLANEOUS', 'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE', 'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT', 'LOGMGR_QUEUE', 'CHECKPOINT_QUEUE', 'REQUEST_FOR_DEADLOCK_SEARCH', 'BROKER_TO_FLUSH', 'BROKER_TASK_STOP', 'DISPATCHER_QUEUE_SEMAPHORE', 'FT_IFTS_SCHEDULER_IDLE_WAIT', 'XE_DISPATCHER_WAIT', 'XE_DISPATCHER_JOIN', 'SQLTRACE_INCREMENTAL_FLUSH_SLEEP')   
                union --bug work around - R2 has fixed this
                SELECT top 1
                    ISNULL(RTRIM(wait_type),'')
                    , CONVERT(decimal(4,2),(CAST((wait_time_ms - signal_wait_time_ms) as decimal(19,2)) /@total_waits) * 100) as PcOfAllWaitTime
                    , wait_time_ms	                
                    , signal_wait_time_ms
                    , max_wait_time_ms
                    , waiting_tasks_count	
                FROM sys.dm_os_wait_stats
                where [wait_type]='MISCELLANEOUS' 
                ORDER BY wait_time_ms DESC 