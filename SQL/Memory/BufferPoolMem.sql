   http://glennberrysqlperformance.spaces.live.com/default.aspx?_c11_BlogPart_BlogPart=blogview&_c=BlogPart&partqs=amonth%3d4%26ayear%3d2010&wa=wsignin1.0&sa=587873557
   
   
    -- Get total buffer usage by database
    SELECT DB_NAME(database_id) AS [Database Name],
    COUNT(*) * 8/1024.0 AS [Cached Size (MB)]
    FROM sys.dm_os_buffer_descriptors
    WHERE database_id > 4 -- exclude system databases
    AND database_id <> 32767 -- exclude ResourceDB
    GROUP BY DB_NAME(database_id)
    ORDER BY [Cached Size (MB)] DESC;


    -- Breaks down buffers used by ALL databases
    SELECT 		
		 OBJECT_NAME(p.[object_id]) AS [object]
		, p.index_id
		, max(db_name(b.database_id)) as db
		, COUNT(*) AS [buffer_count] 
		, COUNT(*)/128 AS [buffer_size_mb]						
    FROM sys.allocation_units AS a
		INNER JOIN sys.dm_os_buffer_descriptors AS b
			ON a.allocation_unit_id = b.allocation_unit_id
		INNER JOIN sys.partitions AS p
			ON a.container_id = p.hobt_id
    WHERE 		
		 p.[object_id] > 100
    GROUP BY p.[object_id], p.index_id
    ORDER BY buffer_count DESC;
    
    
    
    -- Breaks down buffers used by CURRENT database    
    SELECT 		
		 OBJECT_NAME(p.[object_id]) AS [object]
		, p.index_id
		, COUNT(*) AS buffer_pages 
		, convert(decimal(10,3),COUNT(*)/128.0) AS [buffer_size_mb]				
    FROM sys.allocation_units AS au
		INNER JOIN sys.dm_os_buffer_descriptors AS bd
			ON au.allocation_unit_id = bd.allocation_unit_id
		INNER JOIN sys.partitions AS p
			ON au.container_id = p.hobt_id
    WHERE 
		bd.database_id = DB_ID()
		AND p.[object_id] > 100
    GROUP BY p.[object_id], p.index_id
    ORDER BY buffer_pages DESC;
    
    
        -- Breaks down buffers used by CURRENT database AND partitions   
    SELECT 		
		 OBJECT_NAME(p.[object_id]) AS [object]
		, p.index_id
		, COUNT(*) AS buffer_pages 
		, convert(decimal(10,3),COUNT(*)/128.0) AS [buffer_size_mb]	
		,p.partition_number			
    FROM sys.allocation_units AS au
		INNER JOIN sys.dm_os_buffer_descriptors AS bd
			ON au.allocation_unit_id = bd.allocation_unit_id
		INNER JOIN sys.partitions AS p
			ON au.container_id = p.hobt_id
    WHERE 
		bd.database_id = DB_ID()
		AND p.[object_id] > 100
    GROUP BY p.[object_id], p.index_id, p.partition_number
    ORDER BY buffer_pages DESC;
    
    
    select *
    from sys.partitions
    
    select *
    FROM sys.allocation_units