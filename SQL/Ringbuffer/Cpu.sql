--2008
DECLARE @ts_now BIGINT
select @ts_now = cpu_ticks / (cpu_ticks/ms_ticks)  from sys.dm_os_sys_info; 
SELECT --record_id,
        DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS EventTime, 
        SQLProcessUtilization,
        SystemIdle,
        100 - SystemIdle - SQLProcessUtilization AS OtherProcessUtilization
FROM (
        SELECT 
                record.value('(./Record/@id)[1]', 'bigint') AS record_id,
                record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'bigint') AS SystemIdle,
                record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'bigint') AS SQLProcessUtilization,
                TIMESTAMP
        FROM (
                SELECT TIMESTAMP, CONVERT(XML, record) AS record 
                FROM sys.dm_os_ring_buffers 
                WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
                AND record LIKE '% %') AS x
        ) AS y 
ORDER BY record_id DESC


--2005
declare @ts_now bigint
select @ts_now = cpu_ticks / convert(float, cpu_ticks_in_ms) from sys.dm_os_sys_info
select record_id,
      dateadd(ms, -1 * (@ts_now - [timestamp]), GetDate()) as EventTime,
      SQLProcessUtilization,
      SystemIdle,
      100 - SystemIdle - SQLProcessUtilization as OtherProcessUtilization
from (
      select
            record.value('(./Record/@id)[1]', 'int') as record_id,
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') as SystemIdle,
            record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') as SQLProcessUtilization,
            timestamp
      from (
            select timestamp, convert(xml, record) as record
            from sys.dm_os_ring_buffers
            where ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
            and record like '%<SystemHealth>%') as x
      ) as y
order by record_id desc 


--select * from sys.dm_os_sys_info