/*
You can change 'limited' to 'sampled' or 'detailed' for more in depth scanning of the indexes
Remove this where clause if you would like to see system DBs (Where DatabaseID > 4)
Increase or decrease this where clause to adjust the number of fragments per db returned (Where i.rnk <= 25)
Due to the use of DB_ID, the compatibility level all databases must be 90. 
INDEX_ID > 0 omits heap data 
Page_Count > 500 omits indexes with less than 500 pages where defragmentation would not necessarily be helpful
*/



BEGIN
CREATE TABLE #INDEXFRAGINFO
(
DatabaseName nvarchar(128),
DatabaseID smallint,
full_obj_name nvarchar(384),
index_id INT, 
[name] nvarchar(128), 
index_type_desc nvarchar(60), 
index_depth tinyint,
index_level tinyint,
[AVG Fragmentation] float, 
fragment_count bigint,
[Rank] bigint 
)

DECLARE @command VARCHAR(1000) 
SELECT @command = 'Use [' + '?' + '] select ' + '''' + '?' + '''' + ' AS DatabaseName,
DB_ID() AS DatabaseID,
QUOTENAME(DB_NAME(i.database_id), '+ '''' + '"' + '''' +')+ N'+ '''' + '.' + '''' +'+ QUOTENAME(OBJECT_SCHEMA_NAME(i.object_id, i.database_id), '+ '''' + '"' + '''' +')+ N'+ '''' + '.' + '''' +'+ QUOTENAME(OBJECT_NAME(i.object_id, i.database_id), '+ '''' + '"' + '''' +') as full_obj_name, 
i.index_id,
o.name, 
i.index_type_desc, 
i.index_depth,
i.index_level,
i.avg_fragmentation_in_percent as [AVG Fragmentation], 
i.fragment_count, 
i.rnk as Rank
from (
select *, DENSE_RANK() OVER(PARTITION by database_id ORDER BY avg_fragmentation_in_percent DESC) as rnk
from sys.dm_db_index_physical_stats(DB_ID(), default, default, default,'+ '''' + 'limited' + '''' +')
where avg_fragmentation_in_percent >0 AND 
INDEX_ID > 0 AND 
Page_Count > 500 
) as i
join sys.indexes o on o.object_id = i.object_id and o.index_id = i.index_id
where i.rnk <= 25
order by i.database_id, i.rnk;'

INSERT #INDEXFRAGINFO EXEC sp_MSForEachDB @command 

SELECT * FROM #INDEXFRAGINFO
Where DatabaseID > 4
order by [RANK];

DROP TABLE #INDEXFRAGINFO

END
GO


