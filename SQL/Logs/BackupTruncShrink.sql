USE [Gotcha3]
checkpoint
GO

--NULL breaks the backup chain so make sure you will do a FULL backup soon
BACKUP LOG [Gotcha3] TO DISK='NUL'


DBCC SHRINKFILE (N'Gotcha3_log' , 0, TRUNCATEONLY)
GO


DBCC loginfo;

SELECT [name], COUNT(l.database_id) AS 'vlf_count' 
FROM sys.databases s
CROSS APPLY sys.dm_db_log_info(s.database_id) l
GROUP BY [name]
HAVING COUNT(l.database_id) > 100

select * from sys.dm_db_log_info()


