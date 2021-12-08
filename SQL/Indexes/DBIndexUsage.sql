select i.name
	, type_desc
	, user_seeks + user_scans + user_lookups + user_updates AS total_user_operations
	, user_seeks
	, user_scans
	, user_lookups
	, user_updates
	, last_user_seek
	, last_user_scan
	, last_user_lookup
	, last_user_update
	--,*
from sys.dm_db_index_usage_stats us
inner join sys.indexes i
	on us.index_id=i.index_id
	and us.object_id=i.object_id
where database_id = db_id()
ORDER BY user_seeks + user_scans + user_lookups + user_updates DESC