/*============================================================================
  File:     ExtendedEventsWaits.sql

  Summary:  Setup event monitoring for waits

  Date:     October 2010

  SQL Server Version: 10.0.2531.0 (SQL Server 2008 SP1)
------------------------------------------------------------------------------
  Written by Paul S. Randal, SQLskills.com

  (c) 2011, SQLskills.com. All rights reserved.

  For more scripts and sample code, check out 
    http://www.SQLskills.com

  You may alter this code for your own *non-commercial* purposes. You may
  republish altered code as long as you include this copyright and give due
  credit, but you must obtain prior permission before blogging this code.
  
  THIS CODE AND INFORMATION ARE PROVIDED "AS IS" WITHOUT WARRANTY OF 
  ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED 
  TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS FOR A
  PARTICULAR PURPOSE.
============================================================================*/

/*  Cleanup old files
EXECUTE sp_configure 'show advanced options', 1; RECONFIGURE;
EXECUTE sp_configure 'xp_cmdshell', 1; RECONFIGURE; 
EXEC xp_cmdshell 'DEL C:\SQLskills\EE_WaitStats*';
EXECUTE sp_configure 'xp_cmdshell', 0; RECONFIGURE;
EXECUTE sp_configure 'show advanced options', 0; RECONFIGURE;
*/

-- How can we find out all the waits for
-- a particular query?

-- Option 1: clear stats before query
-- Does this work on busy system? No

-- Option 2: extended events

-- Execute code in RunAQuery.sql

-- Drop the session if it exists. 
IF EXISTS (
	SELECT * FROM sys.server_event_sessions
		WHERE name = 'MonitorWaits')
    DROP EVENT SESSION MonitorWaits ON SERVER
GO

-- Create the event session
CREATE EVENT SESSION MonitorWaits ON SERVER
ADD EVENT sqlos.wait_info
	(WHERE sqlserver.session_id = XX/*session_id of new connection*/)
ADD TARGET package0.asynchronous_file_target
    (SET FILENAME = N'C:\SQLskills\EE_WaitStats.xel', 
    METADATAFILE = N'C:\SQLskills\EE_WaitStats.xem')
WITH (max_dispatch_latency = 1 seconds);
GO


-- Start the session
ALTER EVENT SESSION MonitorWaits ON SERVER
STATE = START;
GO

-- Go do the query

-- Stop the event session
ALTER EVENT SESSION MonitorWaits ON SERVER
STATE = STOP;
GO

-- Do we have any rows yet?
SELECT COUNT (*)
	FROM sys.fn_xe_file_target_read_file
	('C:\SQLskills\EE_WaitStats*.xel',
	'C:\SQLskills\EE_WaitStats*.xem', null, null);
GO

-- Create intermediate temp table for raw event data
CREATE TABLE ##RawEventData (
	Rowid		INT IDENTITY PRIMARY KEY,
	event_data	XML);
	
GO

-- Read the file data into intermediate temp table
INSERT INTO ##RawEventData (event_data)
SELECT
    CAST (event_data AS XML) AS event_data
FROM sys.fn_xe_file_target_read_file (
	'C:\SQLskills\EE_WaitStats*.xel',
	'C:\SQLskills\EE_WaitStats*.xem', null, null);
GO

-- And now extract everything nicely
SELECT
	event_data.value (
		'(/event/@timestamp)[1]',
			'DATETIME') AS [Time],
	event_data.value (
		'(/event/data[@name=''wait_type'']/text)[1]',
			'VARCHAR(100)') AS [Wait Type],
	event_data.value (
		'(/event/data[@name=''opcode'']/text)[1]',
			'VARCHAR(100)') AS [Op],
	event_data.value (
		'(/event/data[@name=''duration'']/value)[1]',
			'BIGINT') AS [Duration (ms)],
	event_data.value (
		'(/event/data[@name=''max_duration'']/value)[1]',
			'BIGINT') AS [Max Duration (ms)],
	event_data.value (
		'(/event/data[@name=''total_duration'']/value)[1]',
			'BIGINT') AS [Total Duration (ms)],
	event_data.value (
		'(/event/data[@name=''signal_duration'']/value)[1]',
			'BIGINT') AS [Signal Duration (ms)],
	event_data.value (
		'(/event/data[@name=''completed_count'']/value)[1]',
			'BIGINT') AS [Count]
FROM ##RawEventData;
GO

-- And finally, aggregation
SELECT
	waits.[Wait Type],
	COUNT (*) AS [Wait Count],
	SUM (waits.[Duration]) AS [Total Wait Time (ms)],
	SUM (waits.[Duration]) - SUM (waits.[Signal Duration])
		AS [Total Resource Wait Time (ms)],
	SUM (waits.[Signal Duration]) AS [Total Signal Wait Time (ms)]
FROM 
	(SELECT
		event_data.value (
			'(/event/@timestamp)[1]',
				'DATETIME') AS [Time],
		event_data.value (
			'(/event/data[@name=''wait_type'']/text)[1]',
				'VARCHAR(100)') AS [Wait Type],
		event_data.value (
			'(/event/data[@name=''opcode'']/text)[1]',
				'VARCHAR(100)') AS [Op],
		event_data.value (
			'(/event/data[@name=''duration'']/value)[1]',
				'BIGINT') AS [Duration],
		event_data.value (
			'(/event/data[@name=''signal_duration'']/value)[1]',
				'BIGINT') AS [Signal Duration]
	FROM ##RawEventData
	) AS waits
WHERE waits.op = 'End'
GROUP BY waits.[Wait Type]
ORDER BY [Total Wait Time (ms)] DESC;
GO

-- Cleanup
DROP TABLE ##RawEventData;
GO