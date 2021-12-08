
-- Buffers by object in the buffer pool
SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName], p.[object_id], 
p.index_id, COUNT(*)/128 AS [Buffer size(MB)],  COUNT(*) AS [Buffer_count] 
FROM sys.allocation_units AS a
INNER JOIN sys.dm_os_buffer_descriptors AS b
ON a.allocation_unit_id = b.allocation_unit_id
INNER JOIN sys.partitions AS p
ON a.container_id = p.hobt_id
WHERE b.database_id = DB_ID()
GROUP BY p.[object_id], p.index_id
ORDER BY buffer_count DESC;


