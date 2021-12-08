



--Last 4 hours of cpu
--can go to 256
SELECT TOP 240
--ROW_NUMBER () over (ORDER BY record.value('(Record/@id)[1]', 'int') desc),
dateadd(minute, ROW_NUMBER () over (ORDER BY record.value('(Record/@id)[1]', 'int') desc),CONVERT (varchar(30), getdate(), 126)) AS runtime,
        --record.value('(Record/@id)[1]', 'int') AS record_id,
        --record.value('(Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') AS system_idle_cpu,
        record.value('(Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int') AS sql_cpu_utilization
--into #tempCPU
FROM sys.dm_os_sys_info inf CROSS JOIN (
SELECT timestamp, CONVERT (xml, record) AS record
FROM sys.dm_os_ring_buffers
WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
AND record LIKE '%<SystemHealth>%') AS t
ORDER BY record.value('(Record/@id)[1]', 'int') DESC 
      
      
      
      
SELECT CAST (record AS XML) FROM sys.dm_os_ring_buffers
WHERE ring_buffer_type = 'RING_BUFFER_SCHEDULER_MONITOR'
	

select distinct ring_buffer_type 
FROM sys.dm_os_ring_buffers      

SELECT mxml.value('(//Record/@time)[1]','bigint') as NotificationTime
,mxml.value('(//Record/ResourceMonitor/Notification)[1]','nvarchar(36)') as RM_Notification
,mxml.value('(//Record/ResourceMonitor/Indicators)[1]','int') as RM_Indicators
,mxml.value('(//Record/ResourceMonitor/NodeId)[1]','bigint') as RM_NodeID
,mxml.value('(//Record/MemoryNode/@id)[1]','bigint') as MemNode_ID
,mxml.value('(//Record/MemoryNode/ReservedMemory)[1]','bigint')/1024 as [MemNode_Reserved (MB)]
,mxml.value('(//Record/MemoryNode/CommittedMemory)[1]','bigint')/1024 as [MemNode_Committed (MB)]
,mxml.value('(//Record/MemoryNode/SharedMemory)[1]','bigint')/1024 as [MemNode_Shared (MB)]
,mxml.value('(//Record/MemoryNode/AWEMemory)[1]','bigint')/1024 as [MemNode_AWE (MB)]
,mxml.value('(//Record/MemoryNode/SinglePagesMemory)[1]','bigint')/1024 as [MemNode_SinglePages (MB)]
,mxml.value('(//Record/MemoryNode/MultiplePagesMemory)[1]','bigint')/1024 as [MemNode_MultiPages (MB)]
,mxml.value('(//Record/MemoryNode/CachedMemory)[1]','bigint')/1024 as [MemNode_Cached (MB)]
,mxml.value('(//Record/MemoryRecord/MemoryUtilization)[1]','int')/1024 as [Memory_Utilization (MB)]
,mxml.value('(//Record/MemoryRecord/TotalPhysicalMemory)[1]','bigint')/1024 as [TotalPhysMemory (MB)]
,mxml.value('(//Record/MemoryRecord/AvailablePhysicalMemory)[1]','bigint')/1024 as [AvailPhysMemory (MB)]
,mxml.value('(//Record/MemoryRecord/TotalPageFile)[1]','bigint')/1024 as [TotalPF (MB)]
,mxml.value('(//Record/MemoryRecord/AvailablePageFile)[1]','bigint')/1024 as [AvailPF (MB)]
,mxml.value('(//Record/MemoryRecord/TotalVirtualAddressSpace)[1]','bigint')/1024 as [TotalVAS (MB)]
,mxml.value('(//Record/MemoryRecord/AvailableVirtualAddressSpace)[1]','bigint')/1024 as [AvailVAS (MB)]
,mxml.value('(//Record/MemoryRecord/AvailableExtendedVirtualAddressSpace)[1]','bigint')/1024 as [AvailExtendedVAS (MB)]
FROM (SELECT CAST([record] AS XML)
FROM [sys].[dm_os_ring_buffers]
WHERE [ring_buffer_type] = 'RING_BUFFER_RESOURCE_MONITOR') AS R(mxml)
ORDER BY [NotificationTime] DESC




-- Resource Usage  
select *,-- r.ring_buffer_address,  
r.ring_buffer_type,  
DATEADD (ms, -1 * ((sys.cpu_ticks / sys.ms_ticks) - r.timestamp), GETDATE())  as record_time,  
cast(r.record as xml) record  
from sys.dm_os_ring_buffers r  
cross join sys.dm_os_sys_info sys  
where   
ring_buffer_type='RING_BUFFER_RESOURCE_MONITOR' 
order by 3 desc 