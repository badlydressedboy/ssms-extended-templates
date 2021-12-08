
select * from sys.dm_exec_sessions
where session_id > 50



--EXECUTE Util.Util_ConnectionSummary



SET ANSI_NULLS ON
SET QUOTED_IDENTIFIER ON
SET ANSI_PADDING ON
GO

--Create Util schema if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name='Util') EXECUTE ('CREATE SCHEMA Util')

IF OBJECT_ID('Util.Util_ConnectionSummary', 'P') IS NOT NULL DROP PROCEDURE Util.Util_ConnectionSummary
GO

/**
*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
Util_ConnectionSummary
By Jesse Roberge - YeshuaAgapao@Yahoo.com

Reports summaries of connections, running requests, open transactions, open cursors, and blocking at 3 different levels of aggregation detail.
  (Added 2009-04-28): Also gives the piggiest running request for each grouping along with its identifying information, query batch text, statement text, and XML query plan.
Most useful for finding SPIDs thare being hoggy right now - activity monitor gives session-scoped resource consumption, this aggregates active request scoped resource consumption.
Also useful for quickly finding blocking offenders and finding programs that are not closing connections, cursors or transactions.
Returns 3 result sets:
	Server-wide Total / Summary (No Group By)
	Connections and requests grouped by LoginName, HostName, Programname
	Connections and requests grouped by SessionID (can have more than 1 running request at a time if MARS is enabled)
Orders by ActiveReqCount DESC, OpenTranCount DESC, BlockingRequestCount DESC, BlockedReqCount DESC, ConnectionCount DESC, {group by column(s)}
Can run from a central 'admin' database location.
Requires VIEW_SERVER_STATE permission to work.  DB-owner does not have this permission.
	Sysadmin does have this permission. VIEW_SERVER_STATE can be granted as a separate permission to some or all dbo users.

Required Input Parameters
	none

Optional Input Parameters
	none

Usage:
 	EXECUTE Util.Util_ConnectionSummary

Copyright:
	Licensed under the L-GPL - a weak copyleft license - you are permitted to use this as a component of a proprietary database and call this from proprietary software.
	Copyleft lets you do anything you want except plagarize, conceal the source, or prohibit copying & re-distribution of this script/proc.

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of the
    License, or (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    see <http://www.fsf.org/licensing/licenses/lgpl.html> for the license text.

*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=
**/

CREATE PROCEDURE Util.Util_ConnectionSummary AS

--All connections
SELECT
	ConnectionCount, OpenTranCount, OpenCursorCount, ClosedCursorCount, BlockingRequestCount,
	ActiveReqCount, OpenResultSetCount, ActiveReqOpenTranCount, BlockedReqCount,
	WaitTime, CPUTime, ElapsedTime, Reads, Writes, LogicalReads, [RowCount], GrantedQueryMemoryKB,
	PiggiestRequest.session_id AS PiggiestRequestSessionID,
	PiggiestRequest.login_name AS PiggiestRequestLoginName, PiggiestRequest.host_name AS PiggiestRequestHostName, PiggiestRequest.program_name AS PiggiestRequestProgramName,
	PiggiestRequest.BatchText AS PiggiestRequestBatchText, PiggiestRequest.StatementText AS PiggiestRequestStatementText,
	PiggiestRequest.QueryPlan AS PiggiestRequestQueryPlanXML
FROM
	(
		SELECT
			SUM(ConnectionCount) AS ConnectionCount,
			SUM(CONVERT(bigint, ISNULL(dm_tran_session_transactions.TransactionCount,0))) AS OpenTranCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.OpenCursorCount,0))) AS OpenCursorCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.ClosedCursorCount,0))) AS ClosedCursorCount,
			ISNULL(SUM(dm_exec_blockrequests.BlockingRequestCount),0) AS BlockingRequestCount,
			SUM(dm_exec_requests.ActiveReqCount) AS ActiveReqCount,
			SUM(dm_exec_requests.open_resultset_count) AS OpenResultSetCount,
			SUM(dm_exec_requests.open_transaction_count) AS ActiveReqOpenTranCount,
			SUM(dm_exec_requests.BlockedReqCount) AS BlockedReqCount,
			SUM(dm_exec_requests.wait_time) AS WaitTime,
			SUM(dm_exec_requests.cpu_time) AS CPUTime,
			SUM(dm_exec_requests.total_elapsed_time) AS ElapsedTime,
			SUM(dm_exec_requests.reads) AS Reads,
			SUM(dm_exec_requests.writes) AS Writes,
			SUM(dm_exec_requests.logical_reads) AS LogicalReads,
			SUM(dm_exec_requests.row_count) AS [RowCount],
			SUM(dm_exec_requests.granted_query_memory) AS GrantedQueryMemoryKB
		FROM
			sys.dm_exec_sessions
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS ConnectionCount FROM sys.dm_exec_connections GROUP BY session_id
			) AS dm_exec_connections ON sys.dm_exec_sessions.session_id=dm_exec_connections.session_id
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS TransactionCount FROM sys.dm_tran_session_transactions GROUP BY session_id
			) AS dm_tran_session_transactions ON sys.dm_exec_sessions.session_id=dm_tran_session_transactions.session_id
			LEFT OUTER JOIN (
				SELECT blocking_session_id, COUNT(*) AS BlockingRequestCount FROM sys.dm_exec_requests GROUP BY blocking_session_id
			) AS dm_exec_blockrequests ON sys.dm_exec_sessions.session_id=dm_exec_blockrequests.blocking_session_id
			LEFT OUTER JOIN (
				SELECT session_id, SUM(CASE WHEN is_open=1 THEN 1 ELSE 0 END) AS OpenCursorCount, SUM(CASE WHEN is_open=0 THEN 1 ELSE 0 END) AS ClosedCursorCount
				FROM sys.dm_exec_cursors (0)
				GROUP BY session_id
			) AS dm_exec_cursors ON sys.dm_exec_sessions.session_id=dm_exec_cursors.session_id
			LEFT OUTER JOIN (
				SELECT
					session_id,
					SUM(CONVERT(bigint, open_transaction_count)) AS open_transaction_count,
					SUM(CONVERT(bigint, open_resultset_count)) AS open_resultset_count,
					SUM(CASE WHEN total_elapsed_time IS NULL THEN 0 ELSE 1 END) AS ActiveReqCount,
					SUM(CASE WHEN blocking_session_id <> 0 THEN 1 ELSE 0 END) AS BlockedReqCount,
					SUM(CONVERT(bigint, wait_time)) AS wait_time,
					SUM(CONVERT(bigint, cpu_time)) AS cpu_time,
					SUM(CONVERT(bigint, total_elapsed_time)) AS total_elapsed_time,
					SUM(CONVERT(bigint, reads)) AS Reads,
					SUM(CONVERT(bigint, writes)) AS Writes,
					SUM(CONVERT(bigint, logical_reads)) AS logical_reads,
					SUM(CONVERT(bigint, row_count)) AS row_count,
					SUM(CONVERT(bigint, granted_query_memory*8)) AS granted_query_memory
				FROM sys.dm_exec_requests
				GROUP BY session_id
			) AS dm_exec_requests ON sys.dm_exec_sessions.session_id=dm_exec_requests.session_id
		WHERE sys.dm_exec_sessions.is_user_process=1
	) AS Sessions
	LEFT OUTER JOIN (
		SELECT
			Requests.login_name, Requests.host_name, Requests.program_name, Requests.session_id,
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
					Sessions.login_name, Sessions.host_name, Sessions.program_name, Requests.session_id,
					(Requests.cpu_time+1)*(Requests.reads+Requests.writes+1) AS score,
					Requests.sql_handle, Requests.plan_handle, Requests.statement_start_offset, Requests.statement_end_offset,
					ROW_NUMBER() OVER (ORDER BY (Requests.cpu_time+1)*(Requests.reads+Requests.writes+1)) AS RowNumber
				FROM
					sys.dm_exec_sessions AS Sessions
					JOIN sys.dm_exec_requests AS Requests ON Sessions.session_id=Requests.session_id
			) AS Requests
			CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans
		WHERE RowNumber=1
	) AS PiggiestRequest ON 1=1

--*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

--Connections by LoginName, Hostname, and ProgramName
SELECT
	Sessions.login_name, Sessions.host_name, Sessions.program_name,
	ConnectionCount, OpenTranCount, OpenCursorCount, ClosedCursorCount, BlockingRequestCount,
	ActiveReqCount, OpenResultSetCount, ActiveReqOpenTranCount, BlockedReqCount,
	WaitTime, CPUTime, ElapsedTime, Reads, Writes, LogicalReads, [RowCount], GrantedQueryMemoryKB,
	PiggiestRequest.session_id AS PiggiestRequestSessionID,
	PiggiestRequest.BatchText AS PiggiestRequestBatchText, PiggiestRequest.StatementText AS PiggiestRequestStatementText,
	PiggiestRequest.QueryPlan AS PiggiestRequestQueryPlanXML
FROM
	(
		SELECT
			sys.dm_exec_sessions.login_name, sys.dm_exec_sessions.host_name, sys.dm_exec_sessions.program_name,
			SUM(ConnectionCount) AS ConnectionCount,
			SUM(CONVERT(bigint, ISNULL(dm_tran_session_transactions.TransactionCount,0))) AS OpenTranCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.OpenCursorCount,0))) AS OpenCursorCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.ClosedCursorCount,0))) AS ClosedCursorCount,
			ISNULL(SUM(dm_exec_blockrequests.BlockingRequestCount),0) AS BlockingRequestCount,
			SUM(dm_exec_requests.ActiveReqCount) AS ActiveReqCount,
			SUM(dm_exec_requests.open_resultset_count) AS OpenResultSetCount,
			SUM(dm_exec_requests.open_transaction_count) AS ActiveReqOpenTranCount,
			SUM(dm_exec_requests.BlockedReqCount) AS BlockedReqCount,
			SUM(dm_exec_requests.wait_time) AS WaitTime,
			SUM(dm_exec_requests.cpu_time) AS CPUTime,
			SUM(dm_exec_requests.total_elapsed_time) AS ElapsedTime,
			SUM(dm_exec_requests.reads) AS Reads,
			SUM(dm_exec_requests.writes) AS Writes,
			SUM(dm_exec_requests.logical_reads) AS LogicalReads,
			SUM(dm_exec_requests.row_count) AS [RowCount],
			SUM(dm_exec_requests.granted_query_memory) AS GrantedQueryMemoryKB
		FROM
			sys.dm_exec_sessions
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS ConnectionCount FROM sys.dm_exec_connections GROUP BY session_id
			) AS dm_exec_connections ON sys.dm_exec_sessions.session_id=dm_exec_connections.session_id
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS TransactionCount FROM sys.dm_tran_session_transactions GROUP BY session_id
			) AS dm_tran_session_transactions ON sys.dm_exec_sessions.session_id=dm_tran_session_transactions.session_id
			LEFT OUTER JOIN (
				SELECT blocking_session_id, COUNT(*) AS BlockingRequestCount FROM sys.dm_exec_requests GROUP BY blocking_session_id
			) AS dm_exec_blockrequests ON sys.dm_exec_sessions.session_id=dm_exec_blockrequests.blocking_session_id
			LEFT OUTER JOIN (
				SELECT session_id, SUM(CASE WHEN is_open=1 THEN 1 ELSE 0 END) AS OpenCursorCount, SUM(CASE WHEN is_open=0 THEN 1 ELSE 0 END) AS ClosedCursorCount
				FROM sys.dm_exec_cursors (0)
				GROUP BY session_id
			) AS dm_exec_cursors ON sys.dm_exec_sessions.session_id=dm_exec_cursors.session_id
			LEFT OUTER JOIN (
				SELECT
					session_id,
					SUM(CONVERT(bigint, open_transaction_count)) AS open_transaction_count,
					SUM(CONVERT(bigint, open_resultset_count)) AS open_resultset_count,
					SUM(CASE WHEN total_elapsed_time IS NULL THEN 0 ELSE 1 END) AS ActiveReqCount,
					SUM(CASE WHEN blocking_session_id <> 0 THEN 1 ELSE 0 END) AS BlockedReqCount,
					SUM(CONVERT(bigint, wait_time)) AS wait_time,
					SUM(CONVERT(bigint, cpu_time)) AS cpu_time,
					SUM(CONVERT(bigint, total_elapsed_time)) AS total_elapsed_time,
					SUM(CONVERT(bigint, reads)) AS Reads,
					SUM(CONVERT(bigint, writes)) AS Writes,
					SUM(CONVERT(bigint, logical_reads)) AS logical_reads,
					SUM(CONVERT(bigint, row_count)) AS row_count,
					SUM(CONVERT(bigint, granted_query_memory*8)) AS granted_query_memory
				FROM sys.dm_exec_requests
				GROUP BY session_id
			) AS dm_exec_requests ON sys.dm_exec_sessions.session_id=dm_exec_requests.session_id
		WHERE sys.dm_exec_sessions.is_user_process=1
		GROUP BY sys.dm_exec_sessions.login_name, sys.dm_exec_sessions.host_name, sys.dm_exec_sessions.program_name
	) AS Sessions
	LEFT OUTER JOIN (
		SELECT
			Requests.login_name, Requests.host_name, Requests.program_name, Requests.session_id,
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
					Sessions.login_name, Sessions.host_name, Sessions.program_name, Requests.session_id,
					(Requests.cpu_time+1)*(Requests.reads+Requests.writes+1) AS score,
					Requests.sql_handle, Requests.plan_handle, Requests.statement_start_offset, Requests.statement_end_offset,
					ROW_NUMBER() OVER (PARTITION BY Sessions.login_name, Sessions.host_name, Sessions.program_name ORDER BY (Requests.cpu_time+1)*(Requests.reads+Requests.writes+1)) AS RowNumber
				FROM
					sys.dm_exec_sessions AS Sessions
					JOIN sys.dm_exec_requests AS Requests ON Sessions.session_id=Requests.session_id
			) AS Requests
			CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans
		WHERE RowNumber=1
	) AS PiggiestRequest ON
		Sessions.login_name=PiggiestRequest.login_name
		AND Sessions.host_name=PiggiestRequest.host_name
		AND Sessions.program_name=PiggiestRequest.program_name
ORDER BY
	Sessions.ActiveReqCount DESC, Sessions.OpenTranCount DESC,
	Sessions.BlockingRequestCount DESC, Sessions.BlockedReqCount DESC, Sessions.ConnectionCount DESC,
	Sessions.login_name, Sessions.host_name, Sessions.program_name

--*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

--Connections by session_id
SELECT
	Sessions.session_id, Sessions.login_name, Sessions.host_name, Sessions.program_name,
	Sessions.client_interface_name, Sessions.status,
	ConnectionCount, OpenTranCount, OpenCursorCount, ClosedCursorCount, BlockingRequestCount,
	ActiveReqCount, OpenResultSetCount, ActiveReqOpenTranCount, BlockedReqCount,
	WaitTime, CPUTime, ElapsedTime, Reads, Writes, LogicalReads, [RowCount], GrantedQueryMemoryKB,
	PiggiestRequest.BatchText AS PiggiestRequestBatchText, PiggiestRequest.StatementText AS PiggiestRequestStatementText,
	PiggiestRequest.QueryPlan AS PiggiestRequestQueryPlanXML
FROM
	(
		SELECT
			sys.dm_exec_sessions.session_id,
			MAX(sys.dm_exec_sessions.login_name) AS login_name, MAX(sys.dm_exec_sessions.host_name) AS host_name,
			MAX(sys.dm_exec_sessions.program_name) AS program_name, MAX(sys.dm_exec_sessions.client_interface_name) AS client_interface_name,
			MAX(sys.dm_exec_sessions.status) AS status,
			SUM(ConnectionCount) AS ConnectionCount,
			SUM(CONVERT(bigint, ISNULL(dm_tran_session_transactions.TransactionCount,0))) AS OpenTranCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.OpenCursorCount,0))) AS OpenCursorCount,
			SUM(CONVERT(bigint, ISNULL(dm_exec_cursors.ClosedCursorCount,0))) AS ClosedCursorCount,
			ISNULL(SUM(dm_exec_blockrequests.BlockingRequestCount),0) AS BlockingRequestCount,
			SUM(dm_exec_requests.ActiveReqCount) AS ActiveReqCount,
			SUM(dm_exec_requests.open_resultset_count) AS OpenResultSetCount,
			SUM(dm_exec_requests.open_transaction_count) AS ActiveReqOpenTranCount,
			SUM(dm_exec_requests.BlockedReqCount) AS BlockedReqCount,
			SUM(dm_exec_requests.wait_time) AS WaitTime,
			SUM(dm_exec_requests.cpu_time) AS CPUTime,
			SUM(dm_exec_requests.total_elapsed_time) AS ElapsedTime,
			SUM(dm_exec_requests.reads) AS Reads,
			SUM(dm_exec_requests.writes) AS Writes,
			SUM(dm_exec_requests.logical_reads) AS LogicalReads,
			SUM(dm_exec_requests.row_count) AS [RowCount],
			SUM(dm_exec_requests.granted_query_memory) AS GrantedQueryMemoryKB
		FROM
			sys.dm_exec_sessions
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS ConnectionCount FROM sys.dm_exec_connections GROUP BY session_id
			) AS dm_exec_connections ON sys.dm_exec_sessions.session_id=dm_exec_connections.session_id
			LEFT OUTER JOIN (
				SELECT session_id, COUNT(*) AS TransactionCount FROM sys.dm_tran_session_transactions GROUP BY session_id
			) AS dm_tran_session_transactions ON sys.dm_exec_sessions.session_id=dm_tran_session_transactions.session_id
			LEFT OUTER JOIN (
				SELECT blocking_session_id, COUNT(*) AS BlockingRequestCount FROM sys.dm_exec_requests GROUP BY blocking_session_id
			) AS dm_exec_blockrequests ON sys.dm_exec_sessions.session_id=dm_exec_blockrequests.blocking_session_id
			LEFT OUTER JOIN (
				SELECT session_id, SUM(CASE WHEN is_open=1 THEN 1 ELSE 0 END) AS OpenCursorCount, SUM(CASE WHEN is_open=0 THEN 1 ELSE 0 END) AS ClosedCursorCount
				FROM sys.dm_exec_cursors (0)
				GROUP BY session_id
			) AS dm_exec_cursors ON sys.dm_exec_sessions.session_id=dm_exec_cursors.session_id
			LEFT OUTER JOIN (
				SELECT
					session_id,
					SUM(CONVERT(bigint, open_transaction_count)) AS open_transaction_count,
					SUM(CONVERT(bigint, open_resultset_count)) AS open_resultset_count,
					SUM(CASE WHEN total_elapsed_time IS NULL THEN 0 ELSE 1 END) AS ActiveReqCount,
					SUM(CASE WHEN blocking_session_id <> 0 THEN 1 ELSE 0 END) AS BlockedReqCount,
					SUM(CONVERT(bigint, wait_time)) AS wait_time,
					SUM(CONVERT(bigint, cpu_time)) AS cpu_time,
					SUM(CONVERT(bigint, total_elapsed_time)) AS total_elapsed_time,
					SUM(CONVERT(bigint, reads)) AS Reads,
					SUM(CONVERT(bigint, writes)) AS Writes,
					SUM(CONVERT(bigint, logical_reads)) AS logical_reads,
					SUM(CONVERT(bigint, row_count)) AS row_count,
					SUM(CONVERT(bigint, granted_query_memory*8)) AS granted_query_memory
				FROM sys.dm_exec_requests
				GROUP BY session_id
			) AS dm_exec_requests ON sys.dm_exec_sessions.session_id=dm_exec_requests.session_id
		WHERE sys.dm_exec_sessions.is_user_process=1
		GROUP BY sys.dm_exec_sessions.session_id
	) AS Sessions
	LEFT OUTER JOIN (
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
					(Requests.cpu_time+1)*(Requests.reads+Requests.writes+1) AS score,
					Requests.sql_handle, Requests.plan_handle, Requests.statement_start_offset, Requests.statement_end_offset,
					ROW_NUMBER() OVER (PARTITION BY Requests.session_id ORDER BY (Requests.cpu_time+1)*(Requests.reads+Requests.writes+1)) AS RowNumber
				FROM sys.dm_exec_requests AS Requests
			) AS Requests
			CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS Statements
			CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS QueryPlans
		WHERE RowNumber=1
	) AS PiggiestRequest ON Sessions.session_id=PiggiestRequest.session_id
ORDER BY
	Sessions.ActiveReqCount DESC, Sessions.OpenTranCount DESC,
	Sessions.BlockingRequestCount DESC, Sessions.BlockedReqCount DESC, Sessions.ConnectionCount DESC,
	Sessions.login_name, Sessions.host_name, Sessions.program_name, Sessions.session_id
GO

--*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=*=

