/*
Recommendation: Index should be rebuild when index fragmentation is great than 40%. 
Index should be reorganized when index fragmentation is between 10% to 40%. 
Index rebuilding process uses more CPU and it locks the database resources. 
SQL Server development version and Enterprise version has option ONLINE, which can be turned on when Index is rebuilt. 
ONLINE option will keep index available during the rebuilding. 

Partitions can be rebuilt individually using partition number: Partition = 4;
GO
*/

--check fragmentation first - this is a fast version of various simlar bits of code
SELECT 
	object_name(ps.OBJECT_ID),
	ps.index_id, 
	b.name,
	ps.avg_fragmentation_in_percent
FROM 
	sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
	INNER JOIN sys.indexes AS b ON ps.OBJECT_ID = b.OBJECT_ID
	AND ps.index_id = b.index_id
WHERE 
	ps.database_id = DB_ID()
ORDER BY 
	ps.avg_fragmentation_in_percent desc
	--object_name(ps.OBJECT_ID)
	
	
	

--Index Rebuild : This process drops the existing Index and Recreates the index.
ALTER INDEX ALL ON TableName REBUILD
Partition = 4
with (online = on)


--Index Reorganize : This process physically reorganizes the leaf nodes of the index.
ALTER INDEX ALL ON F_IrSourceDelta REORGANIZE -- ALL will do all indexes on table

ALTER INDEX inc_F_IrSourceDelta_001 ON F_IrSourceDelta REORGANIZE  -- index name specified as opposed to ALL
--43:31 - 15% to 1%





sp_who2
sp_lock
dbcc inputbuffer(94)




