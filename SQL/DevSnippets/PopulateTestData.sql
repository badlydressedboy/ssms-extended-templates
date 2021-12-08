
--drop table TestTableSize3
CREATE TABLE dbo.TestTableSize3
(
	KeyField VARCHAR(900) NOT NULL,
	Field1 VARCHAR(1000) NOT NULL,
	Field2 VARCHAR(1000) NOT NULL,
	Field3 VARCHAR(1000) NOT NULL,
	Field4 VARCHAR(1000) NOT NULL,
	MyDate DATETIME NOT NULL
)
go

begin tran
--commit
CREATE clustered INDEX ixc_TestTableSize3 ON TestTableSize3(KeyField)
go

DECLARE @RowCount INT
DECLARE @RowString VARCHAR(1000)
DECLARE @Random INT
DECLARE @Upper INT
DECLARE @Lower INT
DECLARE @InsertDate DATETIME
declare @bigstr VARCHAR(900)
SET @Lower = -730
SET @Upper = -1
SET @RowCount = 0

WHILE @RowCount < 30000
BEGIN
	SET @RowString = CAST(@RowCount AS VARCHAR(10))
	SELECT @Random = ROUND(((@Upper - @Lower -1) * RAND() + @Lower), 0)
	set @bigstr = REPLICATE('0', 900 - DATALENGTH(@RowString)) + @RowString
	SET @InsertDate = DATEADD(dd, @Random, GETDATE())
	
	
	INSERT INTO TestTableSize3
		(KeyField
		,Field1
		,Field2
		,Field3
		,Field4
		,MyDate)
	VALUES
		( @bigstr
		, @bigstr
		,@bigstr
		,@bigstr
		,@bigstr
		,DATEADD(dd, 4, @InsertDate))

	SET @RowCount = @RowCount + 1
END

SELECT * FROM TestTableSize3
drop table TestTableSize3

WAITFOR DELAY '00:00:5'