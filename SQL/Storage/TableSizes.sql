select obj.name
	, (sum(reserved_page_count) * 8.0)/1024 as "size in MB" 
from sys.dm_db_partition_stats part, sys.objects obj 
where part.object_id = obj.object_id 
and obj.name in ('cases', 'customers', 'addresses', 'screenings')
group by obj.name
order by sum(reserved_page_count) * 8.0 desc
