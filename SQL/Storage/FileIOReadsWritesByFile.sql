SELECT 	
	 name	
	, num_of_reads
	, num_of_writes
FROM 
	sys.dm_io_virtual_file_stats(db_id() ,null) as divfs --params: dbid, fileid
    join sys.master_files as mf
    on mf.database_id = divfs.database_id
    and mf.file_id = divfs.file_id
ORDER BY 
	num_of_reads	
	DESC;

