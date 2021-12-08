--Chunk style deletion

--NOTE: verify the *2* WHERE clauses are all identical

SET NOCOUNT ON

DECLARE @chunksize int
set @chunksize = 2000000

DECLARE @Logdata TABLE(dbname varchar(100), size float, pcused float, status int)

DECLARE @countstring varchar(100)

DECLARE @deletedrows int
SET @deletedrows = 1

DECLARE @logfullpc float

DECLARE @remainingrows int

SELECT @remainingrows = COUNT(1)
  FROM [Tesco].[dbo].[factVehicleVisit201909]
  where OutDatetime < '2019-09-01'
print @remainingrows

WHILE @deletedrows > 0
BEGIN
	DELETE TOP (@chunksize) FROM [Tesco].[dbo].[factVehicleVisit201909]
  where OutDatetime < '2019-09-01'
	SET @deletedrows = @@ROWCOUNT
	
	SET @remainingrows = @remainingrows - @chunksize
	
	DELETE FROM @Logdata
	INSERT @Logdata exec('DBCC SQLPERF(logspace) WITH NO_INFOMSGS')

	SELECT @logfullpc = pcused from @Logdata
	WHERE dbname = 'Tesco'

	SET @countstring = 'Remaining Records: ' + convert(varchar(20),@remainingrows) + ' - ' + convert(varchar(20),@logfullpc) + 'pc of log used'
	--Hack to print immediately
	RAISERROR(@countstring, 0, 1) WITH NOWAIT
		
	CHECKPOINT
	
	waitfor delay '00:00:03'
END

PRINT 'Finished'

SET NOCOUNT OFF



/*
done:
*/
--8405253