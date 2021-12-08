DECLARE @ts_now BIGINT
select @ts_now = cpu_ticks / (cpu_ticks/ms_ticks)  
from sys.dm_os_sys_info; 

--individual errors
SELECT DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS EventTime
	, [error]
	, m.text
FROM (	SELECT TIMESTAMP, RingBuffer.Record.value('Error[1]', 'int') as error
		FROM (SELECT timestamp, CAST(Record AS XML) AS TargetData 
			  FROM sys.dm_os_ring_buffers
			  WHERE ring_buffer_type = 'RING_BUFFER_EXCEPTION') AS Data
		CROSS APPLY TargetData.nodes('//Record/Exception') AS RingBuffer(Record)) derived1
LEFT JOIN sys.messages m
		ON [error] = m.message_id 
		AND m.[language_id] = SERVERPROPERTY('LCID')	
WHERE text is not null		
order by 		
		EventTime desc
		
		
/*		
select *
from sys.messages
where message_id = 3617

--COUNT of errors
SELECT derived2.[count]
	, derived2.[Type]
	, derived2.[error]
	, m.text AS [sys.messages text for error] 
FROM(	SELECT COUNT(*) AS [count]
			, 'RING_BUFFER_EXCEPTION' AS [Type]
			, [error]
		FROM (	SELECT RingBuffer.Record.value('Error[1]', 'int') as error
				FROM (SELECT CAST(Record AS XML) AS TargetData 
					  FROM sys.dm_os_ring_buffers
					  WHERE ring_buffer_type = 'RING_BUFFER_EXCEPTION') AS Data
				CROSS APPLY TargetData.nodes('//Record/Exception') AS RingBuffer(Record)) derived1
		GROUP BY [error])derived2
LEFT JOIN sys.messages m
ON derived2.[error] = m.message_id 
AND m.[language_id] = SERVERPROPERTY('LCID')
ORDER BY [error] 
*/
	

		
				
		
		
		
		