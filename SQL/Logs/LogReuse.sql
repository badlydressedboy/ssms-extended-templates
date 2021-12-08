/*
Verify recovery mode\log reuse state:
log_reuse_wait_desc column is the important one. CHECKPOINT and LOG_BACKUP mean 
those things have to happen where as every other value means what is currently executing 
and being waited for.
*/
select name,  
recovery_model_desc, 
log_reuse_wait, 
log_reuse_wait_desc 
from sys.databases


--FIND LOG USE
--------------------------------------------------------------
DECLARE @DB VARCHAR(100)
SET @DB = 'repro_qa1'
DECLARE @logfullpc float
DECLARE @Logdata TABLE(dbname varchar(100), size float, pcused float, status int)
DELETE FROM @Logdata
INSERT @Logdata exec('DBCC SQLPERF(logspace) WITH NO_INFOMSGS')

SELECT @logfullpc = pcused from @Logdata
WHERE dbname = @DB

SELECT @logfullpc
--------------------------------------------------------------