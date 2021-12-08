declare @dbname varchar(100) = ''
declare @sourcefullpath varchar(1000) = ''
declare @destpath varchar(1000) = ''
declare @sql varchar(4000)

USE MASTER

set @dbname = 'VortexClearerData'
set @sourcefullpath = '\\lcdev05\replicated\LCINF09\VortexClearerData\VortexClearerData_backup_2011_04_15_000008_3254251.bak'
set @destpath = 'C:\Program Files\Microsoft SQL Server\MSSQL10_50.MSSQLSERVER\MSSQL\DATA\' --inc backslash

set @sql = 'ALTER DATABASE [' + @dbname + '] SET  SINGLE_USER WITH ROLLBACK IMMEDIATE'
print @sql
exec(@sql)

set @sql = '
RESTORE DATABASE [' + @dbname + '] 
	FROM  DISK = ''' + @sourcefullpath + ''' WITH  FILE = 1
	,  MOVE ''CLEARERDATA'' TO ''' + @destpath + @dbname + '.mdf''		--LOGICAL AND PHYSICAL NAMES ARE NOT THE SAME SO NEED TO HARDCODE
	,  MOVE ''CLEARERDATA_log'' TO ''' + @destpath + @dbname + '.ldf''	--LOGICAL AND PHYSICAL NAMES ARE NOT THE SAME SO NEED TO HARDCODE
	,  NOUNLOAD
	,  STATS = 10'
exec(@sql)
