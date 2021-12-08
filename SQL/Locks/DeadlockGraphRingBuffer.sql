/*
SELECT * FROM #ring_buffer_data

SELECT * FROM sys.dm_exec_sql_text(0x03000e005ce2795d6b270601969d00000100000000000000)
*/

--DROP TABLE #ring_buffer_data
SELECT	CAST(xest.target_data as XML) xml_data--, *
INTO	#ring_buffer_data
FROM	
	sys.dm_xe_session_targets xest (nolock)
INNER JOIN 
	sys.dm_xe_sessions xes (nolock) on xes.[address] = xest.event_session_address
WHERE 
   xest.target_name = 'ring_buffer' AND
   xes.name = 'system_health'


--select * from #ring_buffer_data

;WITH CTE( event_name, event_time, deadlock_graph )
AS
(
   SELECT
       event_xml.value('(./@name)', 'varchar(1000)') as event_name,
       event_xml.value('(./@timestamp)', 'datetime') as event_time,
       event_xml.value('(./data[@name="xml_report"]/value)[1]', 'varchar(max)') as deadlock_graph
   FROM #ring_buffer_data
       CROSS APPLY xml_data.nodes('//event[@name="xml_deadlock_report"]') n (event_xml)
   WHERE event_xml.value('@name', 'varchar(4000)') = 'xml_deadlock_report'
)
SELECT event_name, event_time, 
    CAST(
       CASE 
           WHEN CHARINDEX('<victim-list/>', deadlock_graph) > 0 THEN
               REPLACE (
                   REPLACE(deadlock_graph, '<victim-list/>', '<deadlock><victim-list>'),
                   '<process-list>', '</victim-list><process-list>') 
           ELSE
               REPLACE (
                   REPLACE(deadlock_graph, '<victim-list>', '<deadlock><victim-list>'),
                   '<process-list>', '</victim-list><process-list>') 
       END 
   AS XML) AS DeadlockGraph
FROM CTE
ORDER BY event_time DESC
DROP TABLE #ring_buffer_data


-------------------refactored version - less easily debuggable but smaller code block----------------------------


;WITH CTE_Deadlocks(event_time, deadlock_graph )
AS
(
   SELECT       
       event_xml.value('(./@timestamp)', 'datetime') as event_time,
       event_xml.value('(./data[@name="xml_report"]/value)[1]', 'varchar(max)') as deadlock_graph
   FROM (SELECT	CAST(xest.target_data as XML) xml_data	
		FROM sys.dm_xe_session_targets xest (nolock)
		INNER JOIN sys.dm_xe_sessions xes (nolock) on xes.[address] = xest.event_session_address
		WHERE xest.target_name = 'ring_buffer' AND
		   xes.name = 'system_health') x
       CROSS APPLY xml_data.nodes('//event[@name="xml_deadlock_report"]') n (event_xml)
   WHERE event_xml.value('@name', 'varchar(4000)') = 'xml_deadlock_report'
)
SELECT event_time, 
    CAST(
       CASE 
           WHEN CHARINDEX('<victim-list/>', deadlock_graph) > 0 THEN
               REPLACE (
                   REPLACE(deadlock_graph, '<victim-list/>', '<deadlock><victim-list>'),
                   '<process-list>', '</victim-list><process-list>') 
           ELSE
               REPLACE (
                   REPLACE(deadlock_graph, '<victim-list>', '<deadlock><victim-list>'),
                   '<process-list>', '</victim-list><process-list>') 
       END 
   AS XML) AS DeadlockGraph
FROM CTE_Deadlocks
ORDER BY event_time DESC


