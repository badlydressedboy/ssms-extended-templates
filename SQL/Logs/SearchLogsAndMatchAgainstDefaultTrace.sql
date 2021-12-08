set nocount on

declare @searchString1 varchar(255)

declare @searchString2 varchar(255)

set @searchString1 = 'xpstar.dll'

set @searchString2 = 'xpstar.dll'

 

declare @logs table (LogNo int, StartDate Datetime, FileSize int)

declare @results table (LogFileNo int, LogDate  Datetime, ProcessInfo varchar(20),Text varchar(max))

insert into @logs EXEC master..sp_enumerrorlogs

 

declare cLogs cursor for select LogNo from @logs

declare @LogNo int

open cLogs

fetch cLogs into @LogNo

while @@fetch_status =0

    begin

    insert into @results(LogDate, ProcessInfo, Text)

    EXEC sp_readerrorlog @LogNo, 1, @searchString1,@searchString2

    update @results set LogFileNo = @LogNo where LogFileNo is null

    fetch cLogs into @LogNo

    end

deallocate cLogs

   

select * from @results

 

declare @logFile varchar(max)

set @logFile = (select path from sys.traces where is_default=1)

 

set @logFile = left(@logFile,len(@LogFile) - charindex('_',reverse(@LogFile))) + '.trc'

set statistics time on

select starttime,*

from fn_trace_gettable(@logFile,null) t

join @results r on  t.StartTime between dateadd(ms,-150,r.logDate) and dateadd(ms,150,r.logdate)

                and t.spid = substring(r.ProcessInfo,5,10) --required to enable a hash join to be used

where t.EventClass = 164

and EventsubClass = 1

set statistics time off 