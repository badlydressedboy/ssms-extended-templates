SET NOCOUNT ON

DECLARE @fraggedThresholdPc int
-----------------------------------------
set @fraggedThresholdPc = 20
-----------------------------------------

IF NOT EXISTS(SELECT * FROM TEMPDB.SYS.TABLES WHERE NAME LIKE '%FraggedIndexes%')
	CREATE TABLE #FraggedIndexes(tablename varchar(1000), indexname varchar(1000), [schema] varchar(50), frag float, SIZEMB DECIMAL(16,2))
DECLARE @FraggedIndexes TABLE(tablename varchar(1000), indexname varchar(1000), [schema] varchar(50), frag float, SIZEMB DECIMAL(16,2))


INSERT @FraggedIndexes
SELECT
	object_name(ps.OBJECT_ID)
	, i.name
	, s.name as [schema]
	, ps.avg_fragmentation_in_percent
	, CONVERT(DECIMAL(16,2),(page_count * 8)/1024.00) as sizeMb
FROM 
	sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, NULL) AS ps
	INNER JOIN sys.indexes AS i ON ps.OBJECT_ID = i.OBJECT_ID
		AND ps.index_id = i.index_id
	INNER JOIN sys.tables t ON i.object_id = t.object_id
	INNER JOIN sys.schemas s on t.schema_id = s.schema_id		
WHERE 
	ps.database_id = DB_ID()
	AND ps.avg_fragmentation_in_percent > @fraggedThresholdPc
	and page_count > 10
	--AND s.name <> 'staging'
ORDER BY 
	ps.avg_fragmentation_in_percent desc
	
--SELECT * FROM #FraggedIndexes	
--STORE DATA

INSERT #FraggedIndexes
SELECT * FROM @FraggedIndexes

--RERUNNABLE POINT
DECLARE @SQL VARCHAR(3000)
DECLARE @INDEXNAME VARCHAR(3000) 
DECLARE @TABLENAME VARCHAR(3000)
DECLARE @FRAGPC VARCHAR(3000) 
DECLARE @SIZEMB VARCHAR(3000)
DECLARE @FraggedIndexes2 TABLE(tablename varchar(1000), indexname varchar(1000), [schema] varchar(50), frag float, SIZEMB DECIMAL(16,2))
INSERT @FraggedIndexes2
SELECT * FROM #FraggedIndexes
ORDER BY SIZEMB

WHILE EXISTS (SELECT TOP 1 * FROM @FraggedIndexes2)
BEGIN
	SET @INDEXNAME = (SELECT  TOP (1) indexname FROM @FraggedIndexes2)
	SET @TABLENAME = (SELECT  TOP (1) [schema] + '.' + tablename FROM @FraggedIndexes2)
	SET @FRAGPC = (SELECT  TOP (1) CONVERT(VARCHAR(50),FRAG) FROM @FraggedIndexes2)
	SET @SIZEMB = (SELECT  TOP (1) CONVERT(VARCHAR(50),SIZEMB) FROM @FraggedIndexes2)
		
	SET @SQL = 'ALTER INDEX [' + @INDEXNAME + '] ON [' + @TABLENAME + '] REBUILD		--SIZE Mb: ' + @SIZEMB + ', FRAG%: ' + @FRAGPC--approx 20% slower with online
	PRINT @SQL
	
	--BEGIN TRY	
	--	exec(@sql)
	--END TRY
	--BEGIN CATCH
	--	PRINT ERROR_MESSAGE()
	--END CATCH
	
	DELETE TOP (1) FROM @FraggedIndexes2
END

