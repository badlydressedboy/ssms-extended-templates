-- This query allows you to see the number of reads and writes on each data and log file for every database running on the instance. It is sorted by average io stall time in milliseconds. This allows you to see which files are waiting the most time for disk I/O. It can help you to decide where to locate individual files based on the disk resources you have available. You can also use it to help persuade someone like a SAN engineer that SQL Server is seeing disk bottlenecks for certain files. 
-- Calculates average stalls per read, per write, and per total input/output for each database file. 
SELECT 
	DB_NAME(divfs.database_id) AS [Database Name]
	, name
	, CAST((io_stall_read_ms + io_stall_write_ms)/(1.0 + num_of_reads + num_of_writes) AS NUMERIC(10,1)) AS [avg_io_stall_ms]
	, physical_name
	, size
	, max_size
	, growth
	, divfs.file_id 
	, io_stall_read_ms
	, num_of_reads
	, CAST(io_stall_read_ms/(1.0 + num_of_reads) AS NUMERIC(10,1)) AS [avg_read_stall_ms]
	, io_stall_write_ms
	, num_of_writes
	, CAST(io_stall_write_ms/(1.0+num_of_writes) AS NUMERIC(10,1)) AS [avg_write_stall_ms]
	, io_stall_read_ms + io_stall_write_ms AS [io_stalls], num_of_reads + num_of_writes AS [total_io]
	FROM 
	sys.dm_io_virtual_file_stats(null,null) as divfs
    join sys.master_files as mf
    on mf.database_id = divfs.database_id
    and mf.file_id = divfs.file_id
ORDER BY 
	--size
	avg_io_stall_ms 
	DESC;

