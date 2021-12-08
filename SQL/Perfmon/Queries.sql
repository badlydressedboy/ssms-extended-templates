--temp table needs to exist to help with required order by clause
declare @formattedcounters table(CounterTime smalldatetime
		, ComputerName varchar(200)
		, cpu NUMERIC(3,2)
		, connections bigint
		, locks bigint
		, lockwaits bigint 
		, MemUseageKb bigint
		, TRowsProcessed bigint
		, TQueries bigint)
insert @formattedcounters
select *
from vw_formattedcounters


select 
	  a.CounterTime
	, a.ComputerName
	, a.cpu
	, a.connections
	, a.locks
	, a.lockwaits	
	, a.TRowsProcessed - b.TRowsProcessed as RowsProcessed
	, a.TQueries - b.TQueries as QueriesComplete
	, a.MemUseageKb
from 
	@formattedcounters a
inner join 
	@formattedcounters b on a.countertime = dateadd(Minute,1,b.countertime)
	and a.computername = b.computername
where 
	a.ComputerName = 'ssaslon12u10007'							       
ORDER BY 
	CounterTime desc