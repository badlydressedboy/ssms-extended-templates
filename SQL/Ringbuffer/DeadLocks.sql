--2008 compliant version
 BEGIN TRY
    ;WITH CTE_Deadlocks(event_time, deadlock_graph )
    AS
    (
        SELECT       
            DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()), event_xml.value('(./@timestamp)', 'datetime')) as event_time,
            event_xml.value('(./data[@name="xml_report"]/value)[1]', 'varchar(max)') as deadlock_graph
        FROM (SELECT	CAST(xest.target_data as XML) xml_data	
            FROM sys.dm_xe_session_targets xest (nolock)
            INNER JOIN sys.dm_xe_sessions xes (nolock) on xes.[address] = xest.event_session_address
            WHERE xest.target_name = 'ring_buffer' AND
                xes.name = 'system_health') x
            CROSS APPLY xml_data.nodes('RingBufferTarget/event[@name="xml_deadlock_report"]') n (event_xml)
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
    ORDER BY event_time  
END TRY
BEGIN CATCH	
    SELECT NULL event_time, NULL deadlock_graph
END CATCH   

            

--2012 confirmed graph returned!!
SELECT  DATEADD(mi, DATEDIFF(mi, GETUTCDATE(), GETDATE()),cast(cast(XEvent.query('data(event/@timestamp)[1]') as varchar(100))as datetime)) AS event_time,
	XEvent.query('(event/data/value/deadlock)[1]') AS DeadlockGraph
FROM    ( 
	SELECT    XEvent.query('.') AS XEvent, XEvent.value('@timestamp', 'datetime2(3)') AS event_time
    FROM      ( 
		SELECT    CAST(target_data AS XML) AS TargetData
		FROM      sys.dm_xe_session_targets st
        JOIN sys.dm_xe_sessions s ON s.address = st.event_session_address
		WHERE s.name = 'system_health' AND st.target_name = 'ring_buffer'
        ) AS Data
    CROSS APPLY TargetData.nodes ('RingBufferTarget/event[@name="xml_deadlock_report"]')
	AS XEventData ( XEvent )
    ) x

