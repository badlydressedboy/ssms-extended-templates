-- pivot experiments

select *
from vw_counters

select 
	counterdatetime, objectname, countername, value
from 
	vw_counters



--very slow compared to joins
SELECT counterdatetime
	, computername
	, [MSAS 2008:Storage Engine Query\Total queries answered] as TQueriesAnswered
	, [Processor(_Total)\% Processor Time] as cpu
FROM vw_counters
PIVOT
(	
  SUM(Value)
  FOR [counter] IN ([Processor(_Total)\% Processor Time]
	, [MSAS 2008:Storage Engine Query\Total queries answered])
)
AS p	
where 
	[MSAS 2008:Storage Engine Query\Total queries answered] IS NOT NULL
	AND [Processor(_Total)\% Processor Time] IS NOT NULL
ORDER BY CounterDateTime desc 