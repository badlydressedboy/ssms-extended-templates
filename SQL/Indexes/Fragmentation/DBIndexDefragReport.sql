-- Sampled returns details about the leaf level only 
-- but includes logical fragmentation as well as physical.
-- Useful on larger tables as it does NOT read the entire
-- table. Good for a detailed (relatively fast) estimate.
SELECT object_name(object_id), index_id, partition_number, avg_fragmentation_in_percent, record_count--, *
FROM sys.dm_db_index_physical_stats
	(db_id(), null, NULL, NULL, 'SAMPLED')
order by avg_fragmentation_in_percent	desc
go