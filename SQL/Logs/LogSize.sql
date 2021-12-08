DBCC SQLPERF(logspace)


--OR FOR A SINGLE DB
--------------------------------------------------------------
DECLARE @DB VARCHAR(100)
SET @DB = 'repro_qa1' --*SET ME*

DECLARE @logfullpc float
DECLARE @Logdata TABLE(dbname varchar(100), size float, pcused float, status int)
DELETE FROM @Logdata
INSERT @Logdata exec('DBCC SQLPERF(logspace) WITH NO_INFOMSGS')

SELECT @logfullpc = pcused from @Logdata
WHERE dbname = @DB

SELECT @logfullpc
--------------------------------------------------------------