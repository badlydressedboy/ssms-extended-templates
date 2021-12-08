select *
from vw_formattedcounters
order by countertime desc



alter view vw_formattedcounters
as
--SELECT SINGLE ROW FOR EVERY SAMPLE DATETIME - COMPUTERNAME HAS TO BE IN WHERE CLAUSE FOR PERF
select cpu.CounterTime --as CounterTime
		, cpu.ComputerName --as ComputerName
		, cpu.cpu as cpu
		, connections.connections as connections
		, locks
		, lockwaits 
		, MemUseageKb
		, TRowsConverted as TRowsProcessed
		, TQueries
from 
    (SELECT
		CounterDateTime,
        CounterTime,
        ComputerName, ObjectName,       
        CONVERT (float,Value) as cpu
    FROM vw_counters nolock
    WHERE ObjectName = 'Processor'
        AND countername = '% Processor Time'
        --AND ComputerName = 'ssaslon12u10007'
        AND InstanceName = '_Total') cpu 
        
INNER JOIN 
        
	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as connections
    FROM vw_counters  nolock  
    WHERE ObjectName = 'MSAS 2008:Connection'
        AND CounterName = 'Current connections') connections
ON cpu.CounterDateTime = connections.CounterDateTime
	AND cpu.ComputerName = connections.ComputerName	

INNER JOIN

	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as locks
    FROM vw_counters nolock   
    WHERE ObjectName = 'MSAS 2008:Locks'
        AND CounterName = 'Current locks') locks	       
ON cpu.CounterDateTime = locks.CounterDateTime
	AND cpu.ComputerName = locks.ComputerName	

INNER JOIN

	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as lockwaits
    FROM vw_counters nolock   
    WHERE ObjectName = 'MSAS 2008:Locks'
        AND CounterName = 'Current lock waits') lockwaits	       
ON cpu.CounterDateTime = lockwaits.CounterDateTime
	AND cpu.ComputerName = lockwaits.ComputerName	

INNER JOIN

	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as MemUseageKb
    FROM vw_counters nolock   
    WHERE ObjectName = 'MSAS 2008:Memory'
        AND CounterName = 'Memory Usage Kb') MemUseageKb	       
ON cpu.CounterDateTime = MemUseageKb.CounterDateTime
	AND cpu.ComputerName = MemUseageKb.ComputerName	

INNER JOIN

	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as TRowsConverted
    FROM vw_counters nolock   
    WHERE ObjectName = 'MSAS 2008:Processing'
        AND CounterName = 'Total Rows converted') RowsConverted	       
ON cpu.CounterDateTime = RowsConverted.CounterDateTime
	AND cpu.ComputerName = RowsConverted.ComputerName	

INNER JOIN

	(SELECT
		CounterDateTime,        
        ComputerName,        
        CONVERT (bigint,Value) as TQueries
    FROM vw_counters nolock   
    WHERE ObjectName = 'MSAS 2008:Storage Engine Query'
        AND CounterName = 'Total queries answered') Queries	       
ON cpu.CounterDateTime = Queries.CounterDateTime
	AND cpu.ComputerName = Queries.ComputerName	



select * 
from vw_formattedcounters





