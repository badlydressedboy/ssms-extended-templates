SELECT top 100 
	  [begin time]
	, [transaction name]
	, SPID
	, [Current LSN]
	, [Previous LSN]
	--, *
FROM ::fn_dblog(NULL, NULL) l
WHERE l.[begin time] is not null
ORDER BY l.[begin time] DESC





--create table tempdb.dbo.mig1tranlog

drop table #mig1tranlog
go
SELECT *
into #mig1tranlog
FROM ::fn_dblog(NULL, NULL)
where [begin time] is not null
go

select count(*)
from #mig1tranlog
go

SELECT [begin time] as bt, [transaction name], operation, context, *
from #mig1tranlog
order by [begin time] desc


--> '2010/06/24 14:36:44:000' 
--and [begin time] < '2010/06/24 14:36:45:000'


SELECT * FROM sys.dm_exec_requests WHERE command LIKE '%ghost%'
/*
tran log entry types:

OPERATION, CONTEXT
LOP_BEGIN_XACT, LCX_NULL


shrinkD = shrink db - This option causes files to be shrunk automatically when more than 25 percent of the file contains unused space.
GhostCleanupTask = 

*/












select cast(TextData as varchar(8000))as TextData into #tt
from [tempdb].[dbo].[profiler_24june]


select TextData,COUNT(*)
from #tt
group by TextData
order by 2 desc

