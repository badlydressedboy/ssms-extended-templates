SET NOCOUNT ON
SET ANSI_WARNINGS OFF

DECLARE @dbname nvarchar(128);
DECLARE @sql nvarchar (1000);
DECLARE @logfile_ID nvarchar(5), @logname nvarchar(128);

create table #files(name varchar(1000), size bigint, filename varchar(2000))

DECLARE DbFind_Cursor CURSOR FAST_FORWARD
	FOR SELECT name FROM master..sysdatabases 
		WHERE name <> 'master' 
			AND name <> 'model' 
			AND name <> 'msdb' 
			AND name <> 'tempdb';
			
OPEN DbFind_Cursor;

FETCH NEXT FROM DbFind_Cursor
	INTO @dbname;
	
WHILE @@FETCH_STATUS = 0
BEGIN
	SET @sql = 'USE ' + QUOTENAME(RTRIM(@dbname)) +
		';insert #files select name, size, filename from dbo.sysfiles'

	PRINT 'Trying ' + @dbname;

	begin try
		EXEC (@sql);
	end try
	BEGIN CATCH
		print 'Not permed on ' + @dbname
	END CATCH
	
	FETCH NEXT FROM DbFind_Cursor
		INTO @dbname;
	
END

CLOSE DbFind_Cursor
DEALLOCATE DbFind_Cursor

select filename, name, size 
from #files
order by filename

drop table #files
