
DECLARE @seconds int = 600
DECLARE @spid int
DECLARE @sql char(200)

DECLARE spid_cursor SCROLL INSENSITIVE CURSOR FOR
SELECT s.spid
FROM 
	master..sysprocesses s
WHERE 
	( datediff( ss, s.last_batch, getdate())) > @seconds
	AND spid > 50 --only target user processes

OPEN spid_cursor

FETCH NEXT FROM spid_cursor INTO @spid

WHILE @@fetch_status = 0
BEGIN
	SELECT @sql = 'kill ' + convert(char(4), @spid)
	PRINT @sql
	EXEC(@sql)
	FETCH NEXT FROM spid_cursor INTO @spid
END

DEALLOCATE spid_cursor
GO


