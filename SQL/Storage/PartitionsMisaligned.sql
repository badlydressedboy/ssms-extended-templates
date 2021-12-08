SELECT
ISNULL(db_name(s.database_id),db_name()) AS DBName
,OBJECT_SCHEMA_NAME(i.object_id,DB_ID()) AS SchemaName
,o.name AS [Object_Name]
,i.name AS Index_name
,i.Type_Desc AS Type_Desc
,DS.name AS DataSpaceName
,ds.type_desc AS DataSpaceTypeDesc
,s.user_seeks
,s.user_scans
,s.user_lookups
,s.user_updates
,s.last_user_seek
,s.last_user_update
FROM sys.objects AS o
JOIN sys.indexes AS i ON o.object_id = i.object_id
JOIN sys.data_spaces DS ON DS.data_space_id = i.data_space_id
LEFT OUTER JOIN sys.dm_db_index_usage_stats AS s ON i.object_id = s.object_id AND i.index_id = s.index_id AND s.database_id = DB_ID()
WHERE o.type = 'u'
AND i.type IN (1, 2)
AND OBJECT_SCHEMA_NAME(i.object_id,DB_ID()) + '.' + O.NAME in
(
SELECT a.name from
(SELECT
OBJECT_SCHEMA_NAME(ob.object_id, DB_ID()) + '.' + OB.NAME AS [name],
ds.type_desc
FROM sys.objects OB
JOIN sys.indexes ind ON ind.object_id = ob.object_id
JOIN sys.data_spaces ds ON ds.data_space_id = ind.data_space_id
GROUP BY OBJECT_SCHEMA_NAME(ob.object_id, DB_ID()) + '.' + ob.name, ds.type_desc ) a GROUP BY a.name HAVING COUNT(*) > 1
)
ORDER BY [OBJECT_NAME] DESC
