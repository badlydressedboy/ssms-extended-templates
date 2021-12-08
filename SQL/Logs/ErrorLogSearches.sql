EXEC sp_readerrorlog 0, 1, 'ERROR'  

EXEC sp_readerrorlog 0, 1, 'deadlock' 

EXEC sp_readerrorlog 0, 1, '2005', 'backup log'  

EXEC sp_readerrorlog 0, 1,'backup'

EXEC master.dbo.xp_readerrorlog 0, 1, 'ERROR',NULL, NULL, NULL, N'DESC'  