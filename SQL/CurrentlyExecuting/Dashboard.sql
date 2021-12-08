SET NOCOUNT ON
--USE MASTER
DECLARE @dbs TABLE(name varchar(100))
DECLARE @currentdb varchar(100)
DECLARE @sql varchar(1000)

IF object_id('tempdb..#DBInfo') IS NOT NULL
BEGIN
   DROP TABLE #DBInfo
END	
CREATE TABLE #DBInfo(name varchar(100), TotalMb float, UsedMb bigint, UsedPc float, LogTotalMb BIGINT, LogUsedPc decimal(10,2), recoverymodel varchar(50), lastbackupcompletion datetime, lastbackupduration int, backup_size bigint , compressed_backup_size bigint,  owner varchar(100))		

IF object_id('tempdb..#DBSizes') IS NOT NULL
BEGIN
   DROP TABLE #DBSizes
END	
CREATE TABLE #DBSizes(name varchar(100), TotalSizeMB bigint, UsedMb bigint, AvailableMB bigint, UsedPc decimal(10,2))

DECLARE @Logdata TABLE(dbname varchar(100), logsize float, logpcused float, status int)
INSERT @Logdata exec('DBCC SQLPERF(logspace) WITH NO_INFOMSGS')


declare @backup_finishes TABLE(database_name varchar(200), last_backup_completion datetime)
insert @backup_finishes(database_name, last_backup_completion)
select database_name
, max(backup_finish_date) as last_backup_completion --, *
from msdb.dbo.backupset
where [Type] = 'D'
group by database_name

declare @backup_finishes_allinfo TABLE(database_name varchar(200), backup_finish_date datetime, backup_duration_mins int, backup_size bigint, compressed_backup_size bigint)
insert @backup_finishes_allinfo(database_name, backup_finish_date, backup_duration_mins, backup_size, compressed_backup_size)
select bus.database_name
, backup_finish_date
, datediff(minute,backup_start_date, backup_finish_date) as backup_duration_mins
, backup_size
, compressed_backup_size
from msdb.dbo.backupset bus
inner join @backup_finishes bf on bus.database_name = bf.database_name
	and bus.backup_finish_date = bf.last_backup_completion
where [Type] = 'D'

--initial fill of dbinfo from single statement
insert #DBInfo(NAME, recoverymodel, LogTotalMb, LogUsedPc, owner, lastbackupcompletion, lastbackupduration, backup_size, compressed_backup_size)
SELECT NAME, recovery_model_desc, logsize, logpcused, SUSER_SNAME(owner_sid) as owner, bfa.backup_finish_date, bfa.backup_duration_mins, bfa.backup_size, bfa.compressed_backup_size
FROM SYS.DATABASES DB
INNER JOIN @Logdata LD ON DB.NAME = LD.[dbname]	
INNER JOIN @backup_finishes_allinfo bfa ON db.name = bfa.database_name
WHERE dATABASE_id > 4

--cursor this:
--select name from sys.databases


EXEC sp_msforeachdb
'
USE ?
INSERT #DBSizes (name) VALUES(''?'')
'


EXEC sp_msforeachdb
'
USE ?

UPDATE #DBSizes
  SET TotalSizeMB = x.TotalSizeMB
, UsedMb = x.UsedMb
, AvailableMB = x.AvailableMB
, UsedPc = x.UsedPc
FROM (
	select SUM(size/128) as TotalSizeMB
	, sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128) as UsedMb
	, SUM(size/128 - CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128) as AvailableMB
	, CONVERT(decimal(10,2) ,(sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS int)/128) / SUM(size/128.0)) * 100) as UsedPc
	from	sys.database_files df
) x	
where name = ''?''	
'

--select * from #DBSizes

update #DBInfo
SET totalMb = DBS.TotalSizeMB
, usedMb = DBS.usedMb
, usedpc = DBS.UsedPc
FROM #DBInfo DBI 
	INNER JOIN #DBSizes DBS 
		ON DBI.NAME = DBS.name


go

select * from #DBInfo
go
------------------------------------------------------------------------------
EXEC xp_fixeddrives
GO
------------------------------------------------------------------------------

--Size of entire instance
select sum(size)/128 TotalInstanceSizeMB from sys.master_files 
------------------------------------------------------------------------------

SELECT CONVERT(CHAR(100), SERVERPROPERTY('Servername')) AS Server , CONVERT(CHAR(100), SERVERPROPERTY('ProductVersion')) AS ProductVersion , CONVERT(CHAR(100), SERVERPROPERTY('ProductLevel')) AS ProductLevel , CONVERT(CHAR(100), SERVERPROPERTY('ResourceLastUpdateDateTime')) AS ResourceLastUpdateDateTime, CONVERT(CHAR(100), SERVERPROPERTY('ResourceVersion')) AS ResourceVersion , CASE WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 1 THEN 'Integrated security' WHEN SERVERPROPERTY('IsIntegratedSecurityOnly') = 0 THEN 'Not Integrated security' END AS IsIntegratedSecurityOnly, CASE WHEN SERVERPROPERTY('EngineEdition') = 1 THEN 'Personal Edition' WHEN SERVERPROPERTY('EngineEdition') = 2 THEN 'Standard Edition' WHEN SERVERPROPERTY('EngineEdition') = 3 THEN 'Enterprise Edition' WHEN SERVERPROPERTY('EngineEdition') = 4 THEN 'Express Edition' END AS EngineEdition , CONVERT(CHAR(100), SERVERPROPERTY('InstanceName')) AS InstanceName , CONVERT(CHAR(100), SERVERPROPERTY('ComputerNamePhysicalNetBIOS')) AS ComputerNamePhysicalNetBIOS, CONVERT(CHAR(100), SERVERPROPERTY('LicenseType')) AS LicenseType , CONVERT(CHAR(100), SERVERPROPERTY('NumLicenses')) AS NumLicenses , CONVERT(CHAR(100), SERVERPROPERTY('BuildClrVersion')) AS BuildClrVersion , CONVERT(CHAR(100), SERVERPROPERTY('Collation')) AS Collation , CONVERT(CHAR(100), SERVERPROPERTY('CollationID')) AS CollationID , CONVERT(CHAR(100), SERVERPROPERTY('ComparisonStyle')) AS ComparisonStyle , CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('EditionID')) = -1253826760 THEN 'Desktop Edition' WHEN SERVERPROPERTY('EditionID') = -1592396055 THEN 'Express Edition' WHEN SERVERPROPERTY('EditionID') = -1534726760 THEN 'Standard Edition' WHEN SERVERPROPERTY('EditionID') = 1333529388 THEN 'Workgroup Edition' WHEN SERVERPROPERTY('EditionID') = 1804890536 THEN 'Enterprise Edition' WHEN SERVERPROPERTY('EditionID') = -323382091 THEN 'Personal Edition' WHEN SERVERPROPERTY('EditionID') = -2117995310 THEN 'Developer Edition' WHEN SERVERPROPERTY('EditionID') = 610778273 THEN 'Enterprise Evaluation Edition' WHEN SERVERPROPERTY('EditionID') = 1044790755 THEN 'Windows Embedded SQL' WHEN SERVERPROPERTY('EditionID') = 4161255391 THEN 'Express Edition with Advanced Services' END AS ProductEdition, CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('IsClustered')) = 1 THEN 'Clustered' WHEN SERVERPROPERTY('IsClustered') = 0 THEN 'Not Clustered' WHEN SERVERPROPERTY('IsClustered') = NULL THEN 'Error' END AS IsClustered, CASE WHEN CONVERT(CHAR(100), SERVERPROPERTY('IsFullTextInstalled')) = 1 THEN 'Full-text is installed' WHEN SERVERPROPERTY('IsFullTextInstalled') = 0 THEN 'Full-text is not installed' WHEN SERVERPROPERTY('IsFullTextInstalled') = NULL THEN 'Error' END AS IsFullTextInstalled, CONVERT(CHAR(100), SERVERPROPERTY('SqlCharSet')) AS SqlCharSet , CONVERT(CHAR(100), SERVERPROPERTY('SqlCharSetName')) AS SqlCharSetName , CONVERT(CHAR(100), SERVERPROPERTY('SqlSortOrder')) AS SqlSortOrderID , CONVERT(CHAR(100), SERVERPROPERTY('SqlSortOrderName')) AS SqlSortOrderName ORDER BY CONVERT(CHAR(100), SERVERPROPERTY('Servername'))
go
------------------------------------------------------------------------------

SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS [Hyperthread Ratio],
cpu_count/hyperthread_ratio AS [Physical CPU Count], 
physical_memory_in_bytes/1048576 AS [Physical Memory (MB)], sqlserver_start_time
FROM sys.dm_os_sys_info;
go
------------------------------------------------------------------------------

	
	
/* EXTRAS:

sp_spaceused
GO

SP_HELPFILE--extended info in filesizes file

DBCC SQLPERF(LOGSPACE)
GO

dbcc opentran

sp_who2--special blocker script in locks folder

dbcc inputbuffer()

sp_lock

--version
EXEC xp_msver
SELECT @@VERSION

EXEC xp_readerrorlog; 

--More detailed than SP_HELPFILE
SELECT  *
FROM    sys.database_files
select * from sys.databases	
*/

	
	
