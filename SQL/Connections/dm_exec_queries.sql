-- sessions is the daddy
select * from sys.dm_exec_sessions
where session_id > 50

-- sessions to connections is 1 to 1
select * from sys.dm_exec_connections
where session_id > 50

-- requests to either of the above is many to 1
select * from sys.dm_exec_requests
where session_id > 50


-- ALL tab - dm_exec_sessions + dm_exec_connections
-- ACTIVE, BLOCKED, BLOCKING tabs based on dm_exec_requests






SELECT
			Requests.session_id,
			Statements.text AS BatchText,
			CASE
				WHEN Requests.sql_handle IS NULL THEN ' '
				ELSE
					SubString(
						Statements.text,
						(Requests.statement_start_offset+2)/2,
						(CASE
							WHEN Requests.statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(MAX),Statements.text))*2
							ELSE Requests.statement_end_offset
						END - Requests.statement_start_offset)/2
					)
			END AS StatementText,
			QueryPlans.query_plan AS QueryPlan
		FROM
			(
				SELECT
					Requests.session_id,
					--(Requests.cpu_time+1)*(Requests.reads+Requests.writes+1) AS score,
					Requests.sql_handle, Requests.plan_handle, Requests.statement_start_offset, Requests.statement_end_offset,
					ROW_NUMBER() OVER (PARTITION BY Requests.session_id ORDER BY (Requests.cpu_time+1)*(Requests.reads+Requests.writes+1)) AS RowNumber
				FROM sys.dm_exec_requests AS Requests
			) AS Requests
			CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans



			
-- recreate, redesign ALL tab - bear in mind active tab
-- potentially a shit load of rows so keep it simple
SELECT s.session_id, host_name, program_name, login_name, status, cpu_time, memory_usage, reads, writes, total_elapsed_time, last_request_end_time
FROM sys.dm_exec_sessions s (nolock)
WHERE s.session_id != @@SPID  
AND s.session_id > 50            
ORDER BY s.session_id 	

-- recreate ACTIVE tab
select r.session_id
from sys.dm_exec_requests r
where session_id > 50

-- going to have to do a full join between all tables and then pick apart active etc in client code
-- only get low level details when the session is highlighted - starttime, isolation level, execution plan etc...poss on bg thread



--daddy query
select Statements.text AS BatchText, * 
from sys.dm_exec_sessions s
inner join sys.dm_exec_connections c
	on s.session_id = c.session_id
left join sys.dm_exec_requests r
	on c.session_id = r.session_id
	CROSS APPLY sys.dm_exec_sql_text(most_recent_sql_handle) AS Statements
where s.session_id > 50




			