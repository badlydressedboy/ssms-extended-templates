--RETURNS THE SUBSET OF XP_FIXEDDRIVES - ONLY DRIVES THAT HAVE DATA FILES
DECLARE @sql nvarchar(1000)
DECLARE @dbname nvarchar(200)

IF object_id('tempdb..#drivefreespace') IS NOT NULL
BEGIN
   DROP TABLE #drivefreespace
END	
CREATE TABLE #drivefreespace(Drive CHAR(1), FreeMb bigint)
INSERT #drivefreespace EXEC ('exec xp_fixeddrives')

IF object_id('tempdb..#useddrives') IS NOT NULL
BEGIN
   DROP TABLE #useddrives
END	
CREATE TABLE #useddrives(Drive CHAR(1))


DECLARE CUR_1 CURSOR for
	SELECT name from sys.databases

OPEN CUR_1
FETCH NEXT FROM CUR_1
INTO @dbname

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = '
		USE [' + @dbname + ']

		INSERT #useddrives 
		select distinct LEFT(physical_name, 1)
		from sys.database_files
		'
		exec(@sql)
	FETCH NEXT FROM CUR_1
	INTO @dbname
END

CLOSE CUR_1
DEALLOCATE CUR_1

SELECT * FROM #drivefreespace
WHERE Drive in (select distinct Drive from #useddrives)

DROP TABLE #useddrives
DROP TABLE #drivefreespace
