-- Author: Nirav Patel (CodeLake - http://www.codelake.com)
-- Profile: http://www.sqlservercentral.com/Forums/UserInfo266085.aspx
-- To find the Recovery Mode(Model) for the 'master' database
SELECT CONVERT(SYSNAME, DATABASEPROPERTYEX(N'master', 'Recovery'))

-- Author: Nirav Patel (CodeLake - http://www.codelake.com)
-- Profile: http://www.sqlservercentral.com/Forums/UserInfo266085.aspx
-- To find the Recovery Mode(Model) for all the databases
SELECT [name] AS [DatabaseName], 
CONVERT(SYSNAME, DATABASEPROPERTYEX(N''+ [name] + '', 'Recovery')) AS 
[RecoveryModel] FROM master.dbo.sysdatabases ORDER BY name


--
-- ALTERNATIVE WAY
--
-- Author: Greg Charles
-- Profile: http://www.sqlservercentral.com/Forums/UserInfo1526.aspx
-- To find the Recovery Mode(Model) for the 'master' database
SELECT recovery_model_desc FROM sys.databases WHERE name = 'master'
