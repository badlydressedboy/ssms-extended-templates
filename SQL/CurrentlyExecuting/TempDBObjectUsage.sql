-- TEMPDB USEAGE
SELECT
user_object_perc = CONVERT(DECIMAL(6,3), u*100.0/(u+i+v+f)),
internal_object_perc = CONVERT(DECIMAL(6,3), i*100.0/(u+i+v+f)),
version_store_perc = CONVERT(DECIMAL(6,3), v*100.0/(u+i+v+f)),
free_space_perc = CONVERT(DECIMAL(6,3), f*100.0/(u+i+v+f)),
[total] = (u+i+v+f)
FROM (
SELECT
u = SUM(user_object_reserved_page_count)*8,		-- USER OBJECTS:		temp tables\vars
i = SUM(internal_object_reserved_page_count)*8,	-- INTERNAL OBJECTS:	sorts\large index hits
v = SUM(version_store_reserved_page_count)*8,	-- VERSION STORE:		isolation level related snapshot data
f = SUM(unallocated_extent_page_count)*8
FROM
sys.dm_db_file_space_usage
) x;