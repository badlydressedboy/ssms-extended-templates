--http://support.microsoft.com/kb/907877/en-us
DBCC MEMORYSTATUS 



--biggest contiguous block in VAS
SELECT convert(varchar,getdate(),120) as [Timestamp]
, (max(region_size_in_bytes)/1024)/1024 [Total max contiguous block size in MB]
from sys.dm_os_virtual_address_dump 
--where region_state = 0×00010000 — MEM_FREE


--largest contiguous block plus the region marked as MEM_RESERVE (this is your non-BPool area reserved during SQL Startup, sometimes referred to as MTL – MemToLeave)
With VASummary(Size,Reserved,Free) AS
(SELECT
    Size = VaDump.Size,
    Reserved =  SUM(CASE(CONVERT(INT, VaDump.Base)^0)
    WHEN 0 THEN 0 ELSE 1 END),
    Free = SUM(CASE(CONVERT(INT, VaDump.Base)^0)
    WHEN 0 THEN 1 ELSE 0 END)
FROM
(
    SELECT  CONVERT(VARBINARY, SUM(region_size_in_bytes))
    AS Size, region_allocation_base_address AS Base
    FROM sys.dm_os_virtual_address_dump 
    WHERE region_allocation_base_address <> '0×0'
    GROUP BY region_allocation_base_address 
UNION  
    SELECT CONVERT(VARBINARY, region_size_in_bytes), region_allocation_base_address
    FROM sys.dm_os_virtual_address_dump
    WHERE region_allocation_base_address  = '0×0'
)
AS VaDump
GROUP BY Size)

SELECT (SUM(CONVERT(BIGINT,Size)*Free)/1024)/1024 AS [Total avail Mem, MB] 
, (CAST(MAX(Size) AS BIGINT)/1024)/1024 AS [Max free size, MB] 
FROM VASummary 
WHERE Free <> 0 


--memory reserved by non-BPool components in SQL Server 
select SUM(virtual_memory_reserved_kb)/1024 as virtual_memory_reserved_mb 
from sys.dm_os_memory_clerks
where type not like '%bufferpool%'


select top 100 *--name, count(*) 
from sys.dm_os_memory_cache_entries
group by name
order by count(*) desc ;

select (sum(single_pages_kb) + sum(multi_pages_kb) ) * 8  / (1024.0 * 1024.0) as plan_cache_in_GB
from sys.dm_os_memory_cache_counters
where type = 'CACHESTORE_SQLCP' or type = 'CACHESTORE_OBJCP'


