

-- Limited returns the leaf level only 
-- and only physical fragmentation details. However, this is very
-- fast as it uses the first level of the non-leaf structure to 
-- see the fragmentation of the leaf level (very clever!).
SELECT * ,  
    STATS_DATE(object_id, index_id) AS statistics_update_date
FROM sys.dm_db_index_physical_stats
	(db_id()
	, object_id('f_irsourcedelta')
	, NULL, NULL, 'LIMITED')
go


-- Sampled returns details about the leaf level only 
-- but includes logical fragmentation as well as physical.
-- Useful on larger tables as it does NOT read the entire
-- table. Good for a detailed (relatively fast) estimate.
SELECT *,  
    STATS_DATE(object_id, index_id) AS statistics_update_date 
FROM sys.dm_db_index_physical_stats
	(db_id(), object_id('f_irsourcedelta'), NULL, NULL, 'SAMPLED')
go


--Show all levels of an index (1 parameter = the clustered index)
SELECT *,  
    STATS_DATE(object_id, index_id) AS statistics_update_date
FROM sys.dm_db_index_physical_stats
    (db_id(), object_id('f_irsourcedelta'), 1, NULL, 'DETAILED')
go


