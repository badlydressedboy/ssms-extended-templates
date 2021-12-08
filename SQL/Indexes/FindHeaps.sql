SELECT object_name(i.object_id )
    ,p.rows
    ,user_seeks
    ,user_scans
    ,user_lookups
    ,user_updates
    ,last_user_seek
    ,last_user_scan
    ,last_user_lookup
FROM sys.indexes i 
    INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
    LEFT OUTER JOIN sys.dm_db_index_usage_stats ius ON i.object_id = ius.object_id AND i.index_id = ius.index_id
WHERE type_desc = 'HEAP'
ORDER BY rows desc