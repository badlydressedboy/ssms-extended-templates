--http://www.mssqltips.com/tip.asp?tip=1476

exec sp_readerrorlog --quite a few optional params

--GET TOP RECENT ENTRIES
DECLARE @a TABLE(logdate datetime, processinfo nvarchar(30), text nvarchar(500))
INSERT @a EXEC sp_readerrorlog
SELECT TOP 200 * FROM @a
ORDER BY logdate DESC