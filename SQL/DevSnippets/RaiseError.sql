--message cannot be given in line - it has to be declared before the error is raised.
declare @message varchar(500)
SET @message = 'Log Full %: ' + convert(varchar(20),@logfullpc) 

RAISERROR(@message, 0, 1) WITH NOWAIT