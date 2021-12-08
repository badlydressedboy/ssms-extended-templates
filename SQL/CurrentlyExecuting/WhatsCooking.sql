/******* WHATS COOKING? *********************
	select session_id, DB_NAME(database_id) db ,command, status
	, case
		when status = 'running' then 'Currently executing batches'
		when status = 'suspended' then 'Waiting for a resource'
		when status = 'runnable' then 'Waiting for scheduler'
		when status = 'pending' then 'Waiting for thread'
	end as status_desc
	, start_time, wait_type, wait_time
	--select *
	from sys.dm_exec_requests
	where session_id > 50 and session_id != @@SPID
	and status in ('running', 'suspended', 'runnable', 'pending')
	order by case
		when status = 'running' then 0
		when status = 'runnable' then 1
		when status = 'pending' then 2
		when status = 'suspended' then 3
	end--status_order
*********************************************/

--kill 102
/*************** SETTINGS ******************/
declare @session_id int = 161
declare @lookup_frag bit = 0
---------------------------------------------


IF OBJECT_ID('tempdb..##query_nodes') IS NOT NULL DROP TABLE ##query_nodes

select db_name(database_id) db_name,  qp.node_id, physical_operator_name, object_name(qp.object_id, qp.database_id) objectname, database_id,  qp.object_id , qp.index_id, CAST('' as varchar(200)) as index_name,  SUM(row_count) row_count, 0 as rows_per_sec, CAST('' as datetime) as stats_date, CAST(0.0 as float) as frag_pc, sum(cpu_time_ms) cpu_time_ms, 0 as cpu_time_ms_per_sec, COUNT(*) thread_count, MAX(plan_handle) plan_handle
into ##query_nodes
from sys.dm_exec_query_profiles qp (nolock)
	left join sys.indexes i (nolock) on qp.object_id = i.object_id and qp.index_id = i.index_id
where session_id = @session_id --and row_count = 0
group by db_name(database_id),  qp.node_id, physical_operator_name, object_name(qp.object_id, qp.database_id), qp.object_id , qp.index_id, i.name, database_id

waitfor delay '00:00:00.250'

update ##query_nodes 
set rows_per_sec = (a.row_count-n.row_count)*4
, cpu_time_ms_per_sec = (a.cpu_time_ms-n.cpu_time_ms)*4
from (
	select db_name(database_id) db_name,  qp.node_id, physical_operator_name, object_name(qp.object_id, qp.database_id) objectname
		, SUM(row_count) row_count, sum(cpu_time_ms) cpu_time_ms
		--, SUM(qp.estimate_row_count) estimate_row_count
		--, SUM(qp.actual_read_row_count), SUM(qp.estimated_read_row_count)
	from sys.dm_exec_query_profiles qp (nolock)
		left join sys.indexes i (nolock) on qp.object_id = i.object_id 
		and qp.index_id = i.index_id

	where session_id = @session_id
	group by db_name(database_id),  qp.node_id, physical_operator_name, object_name(qp.object_id, qp.database_id)
) a
	join  ##query_nodes n 
	on a.node_id = n.node_id
	where ((a.row_count-n.row_count) > 0 ) OR ((a.cpu_time_ms - n.cpu_time_ms) > 0 )
	and n.objectname is not null


delete from ##query_nodes
where rows_per_sec = 0 and cpu_time_ms_per_sec = 0

--select * from ##query_nodes

--populate index-name by db loop
DECLARE @DB_Name varchar(100) 
DECLARE @Command nvarchar(2000) 
DECLARE database_cursor CURSOR FOR 
SELECT db_name FROM ##query_nodes where db_name is not null

OPEN database_cursor 

FETCH NEXT FROM database_cursor INTO @DB_Name 

WHILE @@FETCH_STATUS = 0 
BEGIN 
     SELECT @Command = 'use [' + @DB_Name + '] ; 
	 
update ##query_nodes 
set index_name = isnull(rtrim(i.name), '''')
	, stats_date = STATS_DATE(i.[object_id], n.index_id) 
  from sys.indexes i join ##query_nodes n
  on i.object_id = n.object_id and i.index_id = n.index_id and n.database_id = db_id()
  '
     EXEC sp_executesql @Command 

     FETCH NEXT FROM database_cursor INTO @DB_Name 
END 

CLOSE database_cursor 
DEALLOCATE database_cursor 


if @lookup_frag = 1 
begin
	DECLARE @database_id int,  
		@object_id INT,  
		@index_id int
   
	DECLARE load_cursor CURSOR FOR 
		SELECT db_name, database_id, object_id, index_id 
		FROM ##query_nodes
		where index_id is not null and index_id > 0
 
	OPEN load_cursor 
	FETCH NEXT FROM load_cursor INTO @DB_Name, @database_id, @object_id, @index_id
 
	WHILE @@FETCH_STATUS = 0 
	BEGIN 

	 set @Command = 'use [' + @DB_Name + '] ; 
	 
		update q
		set frag_pc = s.frag_pc
		from 
			(select MAX(avg_fragmentation_in_percent) frag_pc, database_id, object_id, index_id 
			from sys.dm_db_index_physical_stats (' + convert(varchar(10), @database_id) + ', '+convert(varchar(10),@object_id)+'  , '+convert(varchar(10),@index_id)+'  , null   , null )
			GROUP BY database_id, object_id, index_id
			) s
			join ##query_nodes q 
				on s.object_id = q.object_id
				and s.index_id = q.index_id
				and s.database_id = q.database_id
		where q.object_id = '+convert(varchar(10),@object_id)+' and q.database_id = ' + convert(varchar(10),@database_id) + ' and q.index_id = '+convert(varchar(10),@index_id)+'

	  '
	  print @Command 
		 EXEC sp_executesql @Command 

		 FETCH NEXT FROM load_cursor INTO @DB_Name, @database_id, @object_id, @index_id

	end
	CLOSE load_cursor 
	DEALLOCATE load_cursor 
	
end

select node_id, db_name, objectname, index_name, physical_operator_name, row_count, rows_per_sec, cpu_time_ms_per_sec
	, case when datepart(year, stats_date) = '1900' then 'N/A'
	else convert(varchar(100), stats_date)
	end as stats_date1
	, case when objectname is null then 'N/A'
	  when objectname is NOT null and @lookup_frag = 1 then convert(varchar(100), frag_pc)
	else '?'
	end as frag_pc
	, thread_count
from ##query_nodes
order by rows_per_sec desc


declare @plan_handle varbinary(64) = (select top 1 plan_handle from ##query_nodes)
declare @plan xml
--print @plan_handle
select top 1 @plan = query_plan
from sys.dm_exec_query_plan(@plan_handle)

SELECT c.value('.[1]/@EstimatedTotalSubtreeCost', 'nvarchar(max)') as EstimatedTotalSubtreeCost,
       c.value('.[1]/@EstimateRows', 'nvarchar(max)') as EstimateRows,
       c.value('.[1]/@EstimateIO', 'nvarchar(max)') as EstimateIO,
       c.value('.[1]/@EstimateCPU', 'nvarchar(max)') as EstimateCPU,
       -- this returns just the node xml for easier inspection
       c.query('.') as ExecPlanNode        
FROM   -- this returns only nodes with the name RelOp even if they are children of children
       @plan.nodes('//child::RelOp') T(c)
ORDER BY EstimatedTotalSubtreeCost DESC


;WITH xmlnamespaces (default 'http://schemas.microsoft.com/sqlserver/2004/07/showplan')
SELECT DISTINCT
    [Database] = x.value('(@Database)[1]', 'varchar(128)'),
    [Schema]   = x.value('(@Schema)[1]',   'varchar(128)'),
    [Table]    = x.value('(@Table)[1]',    'varchar(128)'),
    [Alias]    = x.value('(@Alias)[1]',    'varchar(128)'),
    [Column]   = x.value('(@Column)[1]',   'varchar(128)')
FROM   @plan.nodes('//ColumnReference') x1(x)












