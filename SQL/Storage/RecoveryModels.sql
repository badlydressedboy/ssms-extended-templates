SELECT [name] AS [DatabaseName], 
CONVERT(SYSNAME, DATABASEPROPERTYEX(N''+ [name] + '', 'Recovery')) AS 
[RecoveryModel] FROM master.dbo.sysdatabases ORDER BY name

