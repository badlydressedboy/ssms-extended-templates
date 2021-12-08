
select db_name(database_id)
	 , sum(user_seeks) + sum(user_scans) + sum(user_lookups) + sum(user_updates) AS total_user_operations
	 , sum(system_seeks) + sum(system_scans) + sum(system_lookups) + sum(system_updates) AS total_system_operations
from sys.dm_db_index_usage_stats us
group by database_id
order by total_user_operations desc
