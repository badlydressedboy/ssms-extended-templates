-- FILL MEM WITH ALL TABLES IN CURRENT DB
use minidbac_minidba

dbcc dropcleanbuffers
dbcc freeproccache

SET NOCOUNT ON
drop table #TMP 
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

	waitfor delay '0:0:1'

	  dbcc dropcleanbuffers

  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) a
  union all
  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) b
  union all
  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) c
  union all
  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) d
  union all
  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) e
  union all
  select * from (
	  select * from [dbo].[usage] u
	  left join [dbo].[ignore_ips] ii on u.ip = ii.ip_address
	  where ii.ip_address is null
  ) f
END

DROP TABLE #TMP

checkpoint

