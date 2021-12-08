--does physical index stats cover individual partitions? - YES - one row is returned for each *level* of the B-tree in each partition

select 	
	  object_name(i.object_id)	
	, i.name
	, p.partition_number
	, VALUE as part_range_value
	, Ips.avg_fragmentation_in_percent
	, fragment_count
	, index_type_desc
	--, index_depth
	--, index_level
	, ISNULL(CONVERT(VARCHAR(50),STATS_DATE(i.OBJECT_ID, i.index_id)),'NO DATA') AS StatsUpdated 
	, ISNULL(CONVERT(VARCHAR(50),DATEDIFF(d,STATS_DATE(i.OBJECT_ID, i.index_id),getdate())) + 'd (' + CONVERT(VARCHAR(50),DATEDIFF(hh,STATS_DATE(i.OBJECT_ID, i.index_id),getdate())) + 'hrs)' ,'NO DATA')  StatsAge	
from 
	sys.dm_db_index_physical_stats(DB_ID(), default, default, default,'limited') Ips --limited\sampled\detailed
join sys.indexes i 
	on Ips.object_id = i.object_id 
	and Ips.index_id = i.index_id
	left join sys.partitions p
		ON p.object_id = i.object_id 
		and p.index_id = i.index_id
		and ips.partition_number = p.partition_number
	INNER JOIN sys.partition_schemes ps
		ON ps.data_space_id = i.data_space_id
	INNER JOIN sys.partition_functions f
		ON f.function_id = ps.function_id
	LEFT JOIN sys.partition_range_values rv
		ON f.function_id = rv.function_id
		AND p.partition_number = rv.boundary_id    
where 
	database_id = db_id()
	and avg_fragmentation_in_percent >10 
order by avg_fragmentation_in_percent desc




--DBCC SHOW_STATISTICS (F_IrSourceDelta, inc_F_IrSourceDelta_Part)

--UPDATE STATISTICS F_IrSourceDelta inc_F_IrSourceDelta_Part
 --   WITH FULLSCAN
    
    
    




