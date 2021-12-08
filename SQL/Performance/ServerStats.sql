-- stats per sec

declare @stats table(reads bigint, writes bigint, packets_sent bigint, packets_received bigint, packet_errors bigint, io float, cpu float, idle float, errors bigint, connections bigint)

insert @stats
--physical io
select @@total_read as reads

	, @@total_write as writes

--network
	, @@pack_sent as packets_sent
	, @@pack_received as packets_received
	, @@packet_errors as packet_errors

--Returns the time that SQL Server has spent performing input and output operations since SQL Server was last started. The result is in CPU time increments ("ticks"), and is cumulative for all CPUs, so it may exceed the actual elapsed time. Multiply by @@TIMETICKS to convert to microseconds.
	, ((@@io_busy * 1.0) * @@TIMETICKS) as io

/*Returns the time that SQL Server has spent working since it was last started. Result is in CPU time increments, or "ticks," and is cumulative for all CPUs, so it may exceed the actual elapsed time. Multiply by @@TIMETICKS to convert to microseconds.*/
	, ((@@cpu_busy * 1.0) * @@TIMETICKS) as cpu

-- Returns the time that SQL Server has been idle since it was last started. The result is in CPU time increments, or "ticks," and is cumulative for all CPUs, so it may exceed the actual elapsed time. Multiply by @@TIMETICKS to convert to microseconds.
	, ((@@idle * 1.0) * @@TIMETICKS) as idle

	, @@total_errors as errors

	, @@connections as connections

--totals
select * from @stats

WAITFOR DELAY '000:00:01' 

--change per sec
select 
	@@total_read - reads as ReadsSec
	, @@total_write - writes as WritesSec
	, @@pack_sent - packets_sent as PacketsSentSec
	, @@pack_received - packets_received as PacketsReceivedSec
	, @@packet_errors - packet_errors as PacketErrorsSec
	, ((@@io_busy * 1.0) * @@TIMETICKS) - io as IoSec
	, ((@@cpu_busy * 1.0) * @@TIMETICKS) - cpu as CpuSec
	--, ((@@idle * 1.0) * @@TIMETICKS) - idle as IdleSec
	, @@total_errors - errors as ErrorsSec
	, @@connections - connections as ConnectionsSec	
from @stats

