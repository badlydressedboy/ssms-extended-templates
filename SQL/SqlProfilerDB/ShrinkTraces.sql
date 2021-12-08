

use [tracedb]
use [tracedb_qa2]
use [tracedb_uat]

sp_spaceused 'dbo.ASTraceTable'

sp_spaceused 'dbo.TaskRequestParameters'

sp_spaceused 'dbo.TaskRequests'




select  top 100 * from dbo.TaskRequests
select  top 100 * from dbo.TaskRequestParameters
select  top 100 * from dbo.ASTraceTable202


begin tran t1

	select distinct tr.taskrequestid
	into oldtaskrequests
	from TaskRequests tr
	inner join TaskRequestParameters trp
	on tr.taskrequestid = trp.taskrequestid
	where insertdate < dateadd(dd,-7,getdate())


	delete from TaskRequests
	where taskrequestid in
	(select taskrequestid from oldtaskrequests)

	delete from TaskRequestParameters
	where taskrequestid in
	(select taskrequestid from oldtaskrequests)

	drop table oldtaskrequests

commit tran t1


delete from dbo.ASTraceTable
where currenttime < dateadd(dd,-7,getdate())

delete
from dbo.ASTraceTable202
where currenttime < dateadd(dd,-7,getdate())



sp_spaceused 
--3537 mb -> 1620

dbcc shrinkdatabase (TraceDB, truncateonly)

dbcc shrinkdatabase (TraceDB_qa2, truncateonly)

dbcc shrinkdatabase (TraceDB_uat, truncateonly)