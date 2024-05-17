--1) top slowest queries lately - will see same query in multiple time chunks
--Run this to get planid of offender
--view query here: https://sqlformat.benlaan.com/app/
select --top 10
	qsp.plan_id, query_id, first_execution_time, count_executions
	, convert(decimal(20,0), avg_duration*0.000001) avg_duration_sec
	, convert(decimal(20,0),(avg_duration*0.000001)*count_executions) total_duration_sec
	, convert(decimal(20,0),avg_cpu_time*0.000001) avg_cpu_time_sec
	, replace(replace(replace(SUBSTRING( query_plan, (CHARINDEX('statementtext=', query_plan)+15), ((CHARINDEX('statementid=', query_plan)-(CHARINDEX('statementtext=', query_plan)+15)-2))), '&#xa;', ' '), '&#xd', ' '), ';', ' ') query
from sys.query_store_plan qsp join sys.query_store_runtime_stats rs
	on qsp.plan_id = rs.plan_id
where 

	rs.first_execution_time > '2024-05-08 09:00:00'
	and rs.last_execution_time < '2024-05-08 11:00:00'

	--rs.first_execution_time > dateadd(dd, -3, getdate())
	--and rs.last_execution_time < dateadd(minute, -120, getdate())--otherwise this query of query store may be included
	and avg_duration > 1000000 --microseconds, look for 1 second and over
	and (avg_duration*0.000001)*count_executions > 10--only interesting if total run time over 15 minutes is > 10 secs
order by (avg_duration*0.000001)*count_executions desc


--2) waits version - non trivial wait types, responsible for > 1% of wait time
-- use planid from step 1 
--view query here: https://sqlformat.benlaan.com/app/
declare @planid bigint = 1108567
select top 30
	qsp.plan_id, qsq.query_id, first_execution_time, count_executions
	, convert(decimal(20,0), avg_duration*0.000001) avg_duration_sec
	--, convert(decimal(20,0),avg_cpu_time*0.000001) avg_cpu_time_sec
	, qsws.wait_category_desc
	, convert(decimal(20,0), avg_query_wait_time_ms*0.001) avg_query_wait_time_sec
	, convert(decimal(20,0),((avg_query_wait_time_ms*0.001)/(avg_duration*0.000001))*100) pc_responsible
	, convert(decimal(20,0),(avg_duration*0.000001)*count_executions) total_duration_sec
	, convert(decimal(20,0),total_query_wait_time_ms*0.001) total_query_wait_time_sec
	, replace(replace(replace(SUBSTRING( query_plan, (CHARINDEX('statementtext=', query_plan)+15), ((CHARINDEX('statementid=', query_plan)-(CHARINDEX('statementtext=', query_plan)+15)-2))), '&#xa;', ' '), '&#xd', ' '), ';', ' ') query
FROM sys.query_store_query AS qsq
JOIN sys.query_store_plan AS qsp
ON qsp.query_id = qsq.query_id
JOIN sys.query_store_runtime_stats AS qsrs
ON qsrs.plan_id = qsp.plan_id
JOIN sys.query_store_wait_stats AS qsws
ON qsws.plan_id = qsrs.plan_id
AND qsws.execution_type = qsrs.execution_type
AND qsws.runtime_stats_interval_id = qsrs.runtime_stats_interval_id
where 
	--qsrs.first_execution_time > dateadd(dd, -2, getdate())
	--and qsrs.last_execution_time < dateadd(minute, -120, getdate())--otherwise this query of query store may be included

	qsrs.first_execution_time > '2024-05-08 07:00:00'
	and qsrs.last_execution_time < '2024-05-08 13:00:00'

	and avg_duration > 1000000 --microseconds, look for 1 second and over for non trivials
	and qsp.plan_id = @planid
	and ((avg_query_wait_time_ms*0.001)/(avg_duration*0.000001))*100 > 1--ignore low wait time waits

order by (avg_duration*0.00001)*count_executions desc



--detect particular wait categories over a time period
select top 1000
	start_time
	, wait_category_desc
	, sum(total_query_wait_time_ms/1000) total_query_wait_time_secs
from sys.query_store_wait_stats ws
	join sys.query_store_runtime_stats_interval si on ws.runtime_stats_interval_id = si.runtime_stats_interval_id
group by wait_category_desc, start_time
--having wait_category_desc in ('network io', 'memory')
 having sum(total_query_wait_time_ms/1000) > 60--filter out trivials, more than 1 min per hour (1 second per minute of this wait)
order by wait_category_desc, start_time desc





