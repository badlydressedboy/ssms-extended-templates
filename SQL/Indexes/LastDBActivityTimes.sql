--last db activity report
SELECT
	db_name([database_id]) dbname,
	last_user_seek = MAX(last_user_seek),
	last_user_scan = MAX(last_user_scan),
	last_user_lookup = MAX(last_user_lookup),
	last_user_update = MAX(last_user_update)
FROM
	sys.dm_db_index_usage_stats
group by db_name([database_id])



