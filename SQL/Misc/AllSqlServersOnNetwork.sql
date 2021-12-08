
/* allow xp_cmdshell

EXEC sp_configure 'show advanced options', 1
GO
RECONFIGURE
go
EXEC sp_configure 'xp_cmdshell', 1
GO
RECONFIGURE
go
*/

exEC master..XP_CMDShell 'OSQL -L'
