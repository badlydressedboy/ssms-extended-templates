-- FILL MEM WITH ALL TABLES IN CURRENT DB
use sprintbase

dbcc dropcleanbuffers
dbcc freeproccache

SET NOCOUNT ON
SELECT TABLE_SCHEMA, TABLE_NAME 
INTO #TMP FROM INFORMATION_SCHEMA.TABLES

SELECT *
FROM #TMP
DECLARE @SQL VARCHAR(1000)
DECLARE @X INT
SELECT @X = COUNT(*) FROM #TMP
WHILE @X > 0
BEGIN
	SET @SQL = 'SELECT * FROM ' + (SELECT TOP 1 TABLE_SCHEMA FROM #TMP) + '.' + (SELECT TOP 1 TABLE_NAME FROM #TMP)
	PRINT @SQL
	EXEC(@SQL)
	DELETE TOP (1) FROM #TMP
	SELECT @X = COUNT(*) FROM #TMP
END

DROP TABLE #TMP

checkpoint
