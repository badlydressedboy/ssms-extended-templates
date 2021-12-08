-- virtual address space summary view

-- generates a list of SQL Server regions

-- showing number of reserved and free regions of a given size 
go

CREATE VIEW VASummary AS

SELECT

    Size = VaDump.Size,

    Reserved =  SUM(CASE(CONVERT(INT, VaDump.Base)^0)

    WHEN 0 THEN 0 ELSE 1 END),

    Free = SUM(CASE(CONVERT(INT, VaDump.Base)^0)

    WHEN 0 THEN 1 ELSE 0 END)

FROM

(

    SELECT 

        CONVERT(VARBINARY, SUM(region_size_in_bytes))

        AS Size, 

        region_allocation_base_address AS Base

    FROM sys.dm_os_virtual_address_dump 

    WHERE region_allocation_base_address <> 0x0

    GROUP BY region_allocation_base_address 

 UNION  

 SELECT CONVERT(VARBINARY, region_size_in_bytes),

 region_allocation_base_address

    FROM sys.dm_os_virtual_address_dump

    WHERE region_allocation_base_address  = 0x0

)

AS VaDump

GROUP BY Size
go
 --available memory in all free regions

SELECT SUM(Size*Free)/1024 AS [Total avail mem, KB] 

FROM VASummary 

WHERE Free <> 0

 --largest available region

SELECT CAST(MAX(Size) AS INT)/1024 AS [Max free size, KB] 

FROM VASummary 

WHERE Free <> 0

 --You can use the sys.dm_os_memory_clerks DMV as follows to find out how much memory SQL Server has allocated through AWE mechanism.

 select  sum(awe_allocated_kb) / 1024 as [AWE allocated, Mb] 

from  sys.dm_os_memory_clerks

--Internal physical

dbcc memorystatus

-- amount of mem allocated though multipage  allocator interface

 select sum(multi_pages_kb) from sys.dm_os_memory_clerks

--You can get a more detailed distribution of memory allocated through the multi-page allocator as

select 

    type, sum(multi_pages_kb)

from 

    sys.dm_os_memory_clerks 

where 

    multi_pages_kb != 0 

group by type

 -- amount of memory consumed by components outside the Buffer pool 

-- note that we exclude single_pages_kb as they come from BPool

-- BPool is accounted for by the next query

select

    sum(multi_pages_kb 

        + virtual_memory_committed_kb

        + shared_memory_committed_kb) as

[Overall used w/o BPool, Kb]

from 

    sys.dm_os_memory_clerks 

where 

    type <> 'MEMORYCLERK_SQLBUFFERPOOL'

 -- amount of memory consumed by BPool

-- note that currenlty only BPool uses AWE

select

    sum(multi_pages_kb 

        + virtual_memory_committed_kb

        + shared_memory_committed_kb

        + awe_allocated_kb) as [Used by BPool with AWE, Kb]

from 

    sys.dm_os_memory_clerks 

where 

    type = 'MEMORYCLERK_SQLBUFFERPOOL'

--Detailed information per component can be obtained as follows. (This includes memory allocated from buffer pool as well as outside the buffer pool.)

 declare @total_alloc bigint 

declare @tab table (

    type nvarchar(128) collate database_default 

    ,allocated bigint

    ,virtual_res bigint

    ,virtual_com bigint

    ,awe bigint

    ,shared_res bigint

    ,shared_com bigint

    ,topFive nvarchar(128)

    ,grand_total bigint

);

-- note that this total excludes buffer pool  committed memory as it represents the largest consumer which is normal

select

    @total_alloc = 

        sum(single_pages_kb 

            + multi_pages_kb 

            + (CASE WHEN type <> 'MEMORYCLERK_SQLBUFFERPOOL' 

                THEN virtual_memory_committed_kb 

                ELSE 0 END) 

            + shared_memory_committed_kb)

from 

    sys.dm_os_memory_clerks 

print 

    'Total allocated (including from Buffer Pool): '  + CAST(@total_alloc as varchar(10)) + ' Kb'

insert into @tab

select

    type

    ,sum(single_pages_kb + multi_pages_kb) as allocated

    ,sum(virtual_memory_reserved_kb) as vertual_res

    ,sum(virtual_memory_committed_kb) as virtual_com

    ,sum(awe_allocated_kb) as awe

    ,sum(shared_memory_reserved_kb) as shared_res 

    ,sum(shared_memory_committed_kb) as shared_com

    ,case  when  (

        (sum(single_pages_kb 

            + multi_pages_kb 

            + (CASE WHEN type <> 'MEMORYCLERK_SQLBUFFERPOOL' 

                THEN virtual_memory_committed_kb 

                ELSE 0 END) 

            + shared_memory_committed_kb))/

            (@total_alloc + 0.0)) >= 0.05 

          then type 

          else 'Other' 

    end as topFive

    ,(sum(single_pages_kb 

        + multi_pages_kb 

        + (CASE WHEN type <> 'MEMORYCLERK_SQLBUFFERPOOL' 

            THEN virtual_memory_committed_kb 

            ELSE 0 END) 

        + shared_memory_committed_kb)) as grand_total 

from 

    sys.dm_os_memory_clerks 

group by type

order by (sum(single_pages_kb + multi_pages_kb

+ (CASE WHEN type <> 

'MEMORYCLERK_SQLBUFFERPOOL' THEN 

virtual_memory_committed_kb ELSE 0 END) + 

shared_memory_committed_kb)) desc

select  * from @tab

 -- top 10 consumers of memory from BPool

select 

    top 10 type, 

    sum(single_pages_kb) as [SPA Mem, Kb]

from 

    sys.dm_os_memory_clerks

group by type 

order by sum(single_pages_kb) desc

--cache

 

select *

from 

    sys.dm_os_memory_cache_clock_hands

where 

    rounds_count > 0

    and removed_all_rounds_count > 0

 --returns information about all entries in caches

select name, count(*)
from sys.dm_os_memory_cache_entries
group by name
order by count(*) desc 
--4401 rows takes 12 when grouped
 
 --slow dmv which is low level enough to join to partitions view
 select * from sys.dm_os_buffer_descriptors
 
 select *
 from sys.dm_os_memory_cache_entries
 --4401 rows takes 124 when not grouped
 
 --minidba query:
 select a.object, i.name, a.buffer_pages, a.buffer_size_mb
                    from 
                    (SELECT 		
                         OBJECT_NAME(p.[object_id]) AS [object]
                        , p.index_id
                        , p.object_id
                        , COUNT(*) AS buffer_pages 
                        , convert(decimal(10,3),COUNT(*)/128.0) AS [buffer_size_mb]	
                        --, *					
                    FROM sys.allocation_units AS au
                        INNER JOIN sys.dm_os_buffer_descriptors AS bd
                            ON au.allocation_unit_id = bd.allocation_unit_id
                        INNER JOIN sys.partitions AS p
                            ON au.container_id = p.hobt_id
                    WHERE 
                        bd.database_id = DB_ID()
                        AND p.[object_id] > 100
                    GROUP BY p.[object_id], p.index_id
                    ) a
                    inner join sys.indexes i
	                    on a.object_id = i.object_id
	                    and a.index_id = i.index_id	
                    ORDER BY buffer_pages DESC
                    
                    
                    
                    