declare @HoursBack smallint = 8;
declare @StartDate datetime = dateadd(hour, -@HoursBack, getutcdate());

;WITH QueryRuntimeStats
AS
(
	select
		 p.plan_id
		,q.query_id
	 	,q.query_hash
		,SUM(rs.count_executions) AS total_executions
		,SUM(rs.count_executions * rs.avg_duration) / 1000 AS total_duration_ms
		,SUM(rs.count_executions * rs.avg_cpu_time) / 1000 AS total_cpu_ms
		,SUM(rs.count_executions * rs.avg_clr_time) / 1000 AS total_clr_time_ms
		,SUM(rs.count_executions * rs.avg_query_max_used_memory) AS total_query_max_used_memory
		,SUM(rs.count_executions * rs.avg_logical_io_reads) AS total_logi_reads
		,SUM(rs.count_executions * rs.avg_logical_io_writes) AS total_logi_writes
		,SUM(rs.count_executions * rs.avg_physical_io_reads) AS total_phys_reads
		,SUM(rs.count_executions * rs.avg_rowcount) AS total_rowcount
		,SUM(rs.count_executions * rs.avg_log_bytes_used) AS total_log_bytes_used
		,SUM(rs.count_executions * rs.avg_tempdb_space_used) AS total_tempdb_space_used
	from sys.query_store_plan p
	join sys.query_store_query q
	  on q.query_id = p.query_id
	join sys.query_store_runtime_stats rs
	  on rs.plan_id = p.plan_id
	join sys.query_store_runtime_stats_interval rsi
	  on rsi.runtime_stats_interval_id = rs.runtime_stats_interval_id
	where rsi.start_time > @StartDate
	group by
		 p.plan_id
		,q.query_id
	 	,q.query_hash
)
,QueryWaitStats
AS
(
	select
		 p.plan_id
		,q.query_id
	 	,q.query_hash
		,ws.wait_category_desc
		,SUM(ws.total_query_wait_time_ms) AS total_wait_time_ms
	from sys.query_store_plan p
	join sys.query_store_query q
	  on q.query_id = p.query_id
	join sys.query_store_wait_stats	ws
	  on ws.plan_id = p.plan_id
	join sys.query_store_runtime_stats_interval rsi
	 on rsi.runtime_stats_interval_id = ws.runtime_stats_interval_id
	where rsi.start_time > @StartDate
	group by
		 p.plan_id
		,q.query_id
	 	,q.query_hash
		,ws.wait_category_desc
)
,QueryWaitStatsByCategory
AS
(
	select *
	from QueryWaitStats 
	PIVOT
	(
		SUM(total_wait_time_ms)
		FOR wait_category_desc IN
		(
			 [Unknown]
			,[CPU]
			,[Worker Thread]
			,[Lock]
			,[Latch]
			,[Buffer Latch]
			,[Buffer IO]
			,[Compilation]
			,[SQL CLR]
			,[Mirroring]
			,[Transaction]
			,[Idle]
			,[Preemptive]
			,[Service Broker]
			,[Tran Log IO]
			,[Network IO]
			,[Parallelism]
			,[Memory]
			,[User Wait]
			,[Tracing]
			,[Full Text Search]
			,[Other Disk IO]
			,[Replication]
			,[Log Rate Governor]
		)
	) AS pvt
)
,QueryWaitStatsTotals
AS
(
	select
		 plan_id
		,query_id
	 	,query_hash
		,SUM(total_wait_time_ms) AS total_wait_time_ms
	from QueryWaitStats
	group by
		 plan_id
		,query_id
	 	,query_hash
)
select
	 rs.plan_id
	,rs.query_id
	,rs.query_hash
	,rs.total_executions
	,rs.total_duration_ms
	,rs.total_cpu_ms
	,rs.total_clr_time_ms
	,rs.total_query_max_used_memory
	,rs.total_logi_reads
	,rs.total_logi_writes
	,rs.total_phys_reads
	,rs.total_rowcount
	,rs.total_log_bytes_used
	,rs.total_tempdb_space_used
	,ws.total_wait_time_ms
	,wsc.[CPU]
	,wsc.[Lock]
	,wsc.[Latch]
	,wsc.[Buffer Latch]
	,wsc.[Buffer IO]
	,wsc.[Memory]
	,wsc.[Tran Log IO]
	,wsc.[Network IO]
	,wsc.[Worker Thread]
	,wsc.[Unknown]
	,wsc.[Compilation]
	,wsc.[SQL CLR]
	,wsc.[Mirroring]
	,wsc.[Transaction]
	,wsc.[Idle]
	,wsc.[Preemptive]
	,wsc.[Service Broker]
	,wsc.[Parallelism]
	,wsc.[User Wait]
	,wsc.[Tracing]
	,wsc.[Full Text Search]
	,wsc.[Other Disk IO]
	,wsc.[Replication]
	,wsc.[Log Rate Governor]
from QueryRuntimeStats rs
left outer join QueryWaitStatsTotals ws
  on rs.plan_id = ws.plan_id
 and rs.query_id = ws.query_id
left outer join QueryWaitStatsByCategory wsc
  on rs.plan_id = wsc.plan_id
 and rs.query_id = wsc.query_id;
