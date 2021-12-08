-- Get total buffer usage by database
    SELECT DB_NAME(database_id) AS [Database Name],
    COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
    FROM sys.dm_os_buffer_descriptors
    WHERE database_id > 4 -- exclude system databases
    AND database_id <> 32767 -- exclude ResourceDB
    GROUP BY DB_NAME(database_id)
    ORDER BY [Cached Size (MB)] DESC;
    
    
    -- Breaks down buffers used by current database by 
    -- object (table, index) in the buffer cache
    SELECT OBJECT_NAME(p.[object_id]) AS [ObjectName],  
    p.index_id, COUNT(*)/128 AS [buffer size(MB)],  
    COUNT(*) AS [buffer_count] 
    FROM sys.allocation_units AS a
    INNER JOIN sys.dm_os_buffer_descriptors AS b
    ON a.allocation_unit_id = b.allocation_unit_id
    INNER JOIN sys.partitions AS p
    ON a.container_id = p.hobt_id
    WHERE b.database_id = DB_ID()
    AND p.[object_id] > 100
    GROUP BY p.[object_id], p.index_id
    ORDER BY buffer_count DESC;
    
    
  SELECT *
    FROM sys.allocation_units AS a
    INNER JOIN sys.dm_os_buffer_descriptors AS b
    ON a.allocation_unit_id = b.allocation_unit_id
    INNER JOIN sys.partitions AS p
    ON a.container_id = p.hobt_id
    WHERE b.database_id = DB_ID()
    AND p.[object_id] > 100    
    
select *
from sys.dm_os_buffer_descriptors   
--379,835 pages - same as database section of buffers graph

select 379835 * 8

--3038680 kb
select 3038680/1024
--2967 Mb